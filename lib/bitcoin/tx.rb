require_relative '../bitcoin_data_io'
require_relative '../encoding_helper'
require_relative '../hash_helper'
require_relative 'script'
require 'net/http'
require 'uri'
require 'stringio'

module Bitcoin
  class Tx
    include EncodingHelper
    SIGHASH_ALL = 1
    SIGHASH_NONE = 2
    SIGHASH_SINGLE = 3

    class TxIn
      include EncodingHelper

      def initialize(prev_tx, prev_index, script_sig=nil, sequence=0xffffffff)
        @prev_tx = prev_tx
        @prev_index = prev_index
        @script_sig = script_sig || Script.new
        @sequence = sequence
      end

      def self.parse(_io)
        io = BitcoinDataIO(_io)

        prev_tx = io.read_le(32)
        prev_index = io.read_le_int32
        script_sig = Script.parse io
        sequence = io.read_le_int32

        new(prev_tx, prev_index, script_sig, sequence)
      end

      def fetch_tx(testnet: false)
        tx_id = prev_tx.unpack1('H*')

        TxFetcher.fetch tx_id, testnet: testnet
      end

      def script_pubkey(testnet: false)
        tx = fetch_tx testnet: testnet
        tx.outs[prev_index].script_pubkey
      end

      def serialize
        result = prev_tx.reverse
        result << to_bytes(prev_index, 4, 'little')
        result << @script_sig.serialize
        result << to_bytes(sequence, 4, 'little')
      end

      attr_accessor :prev_tx, :prev_index, :script_sig, :sequence
    end

    class TxOut
      include EncodingHelper

      def self.parse(_io)
        io = BitcoinDataIO(_io)

        new.tap do |obj|
          obj.amount = io.read_le_int64
          obj.script_pubkey = Script.parse io
        end
      end

      def serialize
        result = int_to_little_endian(@amount, 8)
        result += @script_pubkey.serialize
      end

      attr_accessor :amount, :script_pubkey
    end

    class TxFetcher
      extend EncodingHelper

      def self.base_url(testnet: false)
        testnet ? 'https://blockstream.info/testnet/api' : 'https://blockstream.info/api'
      end

      def self.fetch(tx_id, testnet: false)
        url = URI("#{base_url(testnet: testnet)}/tx/#{tx_id}/hex")
        res = Net::HTTP.get(url)
        raw = from_hex_to_bytes(res)
        if raw[4] == "\x00"
          raw = raw[...4] + raw[6...]
          tx = Tx.parse(StringIO.new(raw), testnet: testnet)
          tx.locktime = from_bytes(raw[-4...], 'little')
        else
          tx = Tx.parse(StringIO.new(raw), testnet: testnet)
        end

        raise "not the same id: #{tx.id.first} vs #{tx_id}" if tx.id.first != tx_id

        tx
      end
    end

    def self.parse(_io, _options = {})
      io = BitcoinDataIO(_io)

      new(_options).tap do |tx|
        tx.version = io.read_le_int32
        io.read_varint.times { tx.ins << TxIn.parse(io) }
        io.read_varint.times { tx.outs << TxOut.parse(io) }
        tx.locktime = io.read_le_int32
      end
    end

    def id
      HashHelper.hash256(serialize).reverse.unpack('H*')
    end

    def serialize
      result = to_bytes(version, 4, 'little')
      result << encode_varint(ins.size)
      result << ins.map(&:serialize).join
      result << encode_varint(outs.size)
      result << outs.map(&:serialize).join
      result << to_bytes(locktime, 4, 'little')

      result
    end

    attr_accessor :version, :locktime, :ins, :outs

    def initialize(tx_fetcher: nil, testnet: false)
      @tx_fetcher = tx_fetcher
      @ins = []
      @outs = []
      @testnet = testnet
    end

    def fee
      @fee ||= calculate_fee
    end

    def sig_hash(input_index)
      result = int_to_little_endian version, 4
      result << encode_varint(ins.size)

      ins.each_with_index do |input, index|
        if index == input_index
          result << TxIn.new(
            input.prev_tx,
            input.prev_index,
            input.script_pubkey(testnet: @testnet),
            input.sequence
          ).serialize
        else
          result << TxIn.new(
            input.prev_tx,
            input.prev_index,
            nil,
            input.sequence
          ).serialize
        end
      end

      result << encode_varint(outs.size)
      outs.each do |output|
        result << output.serialize
      end

      result << int_to_little_endian(locktime, 4)
      result << int_to_little_endian(SIGHASH_ALL, 4)
      hash256 = HashHelper.hash256 result

      from_bytes hash256, 'big'
    end

    def verify_input(input_index)
      tx_in = ins[input_index]
      script_pubkey = tx_in.script_pubkey testnet: @testnet
      z = sig_hash(input_index)
      combined = tx_in.script_sig + script_pubkey
      combined.evaluate(z)
    end

    def verify?
      return false if @fee.negative?

      ins.each_with_index  do |input, index|
        return false unless verify_input index
      end

      true
    end

    def sign_input(input_index, private_key)
      z = sig_hash(input_index)
      der = private_key.sign(z).der
      sig = der + to_bytes(SIGHASH_ALL, 1, 'big')
      sec = private_key.point.sec()
      ins[input_index].script_sig = Script.new([sig, sec])

      verify_input(input_index)
    end

    private

    def calculate_fee
      raise 'transaction fetcher not provided' if @tx_fetcher.nil?

      input_amount = ins.sum do |input|
        raw_input_tx = @tx_fetcher.fetch(input.prev_tx)
        input_tx = Bitcoin::Tx.parse(raw_input_tx)
        input_tx.outs[input.prev_index].amount
      end

      output_amount = outs.sum(&:amount)

      input_amount - output_amount
    end
  end
end
