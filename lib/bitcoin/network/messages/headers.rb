# encoding: ascii-8bit
require_relative '../../../bitcoin_data_io'
require_relative './base_message'

module Bitcoin
  module Network
    module Messages
      class Headers < BaseMessage
        COMMAND = "headers"

        def initialize(blocks:)
          @blocks = blocks
        end

        attr_accessor :blocks

        def self.parse(_io)
          io = BitcoinDataIO(_io)

          num_headers = io.read_varint
          blocks = []

          num_headers.times do
            blocks << Bitcoin::Block.parse(io)
            num_txs = io.read_varint

            raise RuntimeError('number of txs not 0') unless num_txs.zero?
          end

          new(blocks: blocks)
        end
      end
    end
  end
end
