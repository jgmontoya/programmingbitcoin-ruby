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
