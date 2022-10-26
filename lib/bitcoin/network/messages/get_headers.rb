# encoding: ascii-8bit
require_relative './base_message'

module Bitcoin
  module Network
    module Messages
      class GetHeaders < BaseMessage
        COMMAND = "getheaders"

        def initialize(version: 70015, num_hashes: 1, start_block: nil, end_block: nil)
          @version = version
          @num_hashes = num_hashes

          raise 'a start block is required' if start_block.nil?

          @start_block = start_block
          @end_block = end_block.nil? ? "\x00" * 32 : end_block
        end

        def serialize
          result = int_to_little_endian(@version, 4)
          result << encode_varint(@num_hashes)
          result << @start_block.reverse
          result << @end_block.reverse

          result
        end
      end
    end
  end
end
