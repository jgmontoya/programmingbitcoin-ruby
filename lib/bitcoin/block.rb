require_relative '../bitcoin_data_io'
require_relative '../encoding_helper'

module Bitcoin
  class Block
    include EncodingHelper
    extend EncodingHelper

    def initialize(version, prev_block, merkle_root, timestamp, bits, nonce)
      @version = version
      @prev_block = prev_block
      @merkle_root = merkle_root
      @timestamp = timestamp
      @bits = bits
      @nonce = nonce
    end

    attr_accessor :version, :prev_block, :merkle_root, :timestamp, :bits, :nonce

    def self.parse(io)
      io = BitcoinDataIO(io)

      version = little_endian_to_int(io.read(4))
      prev_block = io.read_le(32)
      merkle_root = io.read_le(32)
      timestamp = little_endian_to_int(io.read(4))
      bits = io.read(4)
      nonce = io.read(4)

      new(version, prev_block, merkle_root, timestamp, bits, nonce)
    end
  end
end
