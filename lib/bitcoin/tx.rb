require_relative '../bitcoin_data_io'

module Bitcoin
  class Tx
    class TxIn
      def self.parse(_io)
        io = BitcoinDataIO(_io)

        new.tap do |obj|
          obj.prev_tx = io.gets_le(32)
          obj.prev_index = io.get_le_integer
          obj.raw_script_sig = _io.gets(io.get_varint)
          obj.sequence = io.get_le_integer
        end
      end

      attr_accessor :prev_tx, :prev_index, :raw_script_sig, :sequence
    end

    class TxOut
      def self.parse(_io)
        io = BitcoinDataIO(_io)

        new.tap do |obj|
          obj.amount = io.get_le_long
          obj.raw_script_pubkey = _io.gets(io.get_varint)
        end
      end

      attr_accessor :amount, :raw_script_pubkey
    end

    def self.parse(_io)
      io = BitcoinDataIO(_io)

      new.tap do |tx|
        tx.version = io.get_le_integer
        io.get_varint.times { tx.ins << TxIn.parse(io) }
        io.get_varint.times { tx.outs << TxOut.parse(io) }
        tx.locktime = io.get_le_integer
      end
    end

    attr_accessor :version, :locktime, :ins, :outs

    def initialize
      @ins = []
      @outs = []
    end
  end
end
