require_relative '../bitcoin_data_io'
require_relative '../encoding_helper'
require_relative '../hash_helper'

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

    def serialize
      result = to_bytes(version, 4, 'little')
      result << prev_block.reverse
      result << merkle_root.reverse
      result << to_bytes(timestamp, 4, 'little')
      result << bits
      result << nonce
    end

    def hash
      HashHelper.hash256(serialize).reverse
    end

    def bip9?
      version >> 29 == 0b001
    end

    def bip91?
      (version >> 4) & 1 == 1
    end

    def bip141?
      (version >> 1) & 1 == 1
    end
  end
end
