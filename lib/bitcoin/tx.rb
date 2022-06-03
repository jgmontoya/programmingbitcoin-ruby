require_relative '../bitcoin_data_io'

module Bitcoin
  class Tx
    class TxIn
      def self.parse(_io)
        io = BitcoinDataIO(_io)

        new.tap do |obj|
          obj.prev_tx = io.read_le(32)
          obj.prev_index = io.read_le_int32
          obj.raw_script_sig = _io.read(io.read_varint)
          obj.sequence = io.read_le_int32
        end
      end

      attr_accessor :prev_tx, :prev_index, :raw_script_sig, :sequence
    end

    class TxOut
      def self.parse(_io)
        io = BitcoinDataIO(_io)

        new.tap do |obj|
          obj.amount = io.read_le_int64
          obj.raw_script_pubkey = _io.read(io.read_varint)
        end
      end

      attr_accessor :amount, :raw_script_pubkey
    end

    def self.parse(_io)
      io = BitcoinDataIO(_io)

      new.tap do |tx|
        tx.version = io.read_le_int32
        io.read_varint.times { tx.ins << TxIn.parse(io) }
        io.read_varint.times { tx.outs << TxOut.parse(io) }
        tx.locktime = io.read_le_int32
      end
    end

    attr_accessor :version, :locktime, :ins, :outs

    def initialize
      @ins = []
      @outs = []
    end
  end
end
