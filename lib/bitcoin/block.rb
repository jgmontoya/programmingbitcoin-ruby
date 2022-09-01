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

    def self.target_to_bits(target)
      raw_bytes = to_bytes(target, 32, 'big').sub(/^\x00*/, "")
      if little_endian_to_int(raw_bytes[0]) > 0x7f
        exponent = raw_bytes.length + 1
        coefficient = "x\00#{raw_bytes[0...2]}"
      else
        exponent = raw_bytes.length
        coefficient = raw_bytes[0...3]
      end
      coefficient.reverse + to_bytes(exponent, 1, 'little')
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

    def target
      exponent = little_endian_to_int(bits[-1])
      coefficient = little_endian_to_int(bits[0...-1])
      coefficient * 256**(exponent - 3)
    end

    def difficulty
      0xffff00000000000000000000000000002e8000000000000000000000 / target
    end

    def pow_valid?
      block_header_hash = HashHelper.hash256(serialize)
      little_endian_to_int(block_header_hash) < target
    end
  end
end
