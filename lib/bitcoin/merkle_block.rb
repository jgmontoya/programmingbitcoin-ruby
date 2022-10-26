require_relative '../bitcoin_data_io'
require_relative '../encoding_helper'
require_relative '../merkle_tree'

module Bitcoin
  class MerkleBlock
    include EncodingHelper
    extend EncodingHelper

    def initialize(version, prev_block, merkle_root, timestamp, bits, nonce,
      total_tx, tx_hashes, flags)

      @version = version
      @prev_block = prev_block
      @merkle_root = merkle_root
      @timestamp = timestamp
      @bits = bits
      @nonce = nonce
      @total_tx = total_tx
      @tx_hashes = tx_hashes
      @flags = flags
    end

    attr_accessor :version, :prev_block, :merkle_root, :timestamp, :bits, :nonce,
                  :total_tx, :tx_hashes, :flags

    def self.parse(io)
      io = BitcoinDataIO(io)

      version = little_endian_to_int(io.read(4))
      prev_block = io.read_le(32)
      merkle_root = io.read_le(32)
      timestamp = little_endian_to_int(io.read(4))
      bits = io.read(4)
      nonce = io.read(4)
      total_tx = little_endian_to_int(io.read(4))
      num_hashes = io.read_varint
      tx_hashes = []
      num_hashes.times { tx_hashes << io.read_le(32) }
      # refactor
      num_flags = io.read_varint
      flags = io.read_le(num_flags)

      new(version, prev_block, merkle_root, timestamp, bits, nonce, total_tx, tx_hashes, flags)
    end

    def valid?
      flag_bits = bytes_to_bit_field(@flags.reverse)
      hashes = @tx_hashes.map(&:reverse)
      tree = MerkleTree.new(@total_tx)
      tree.populate_tree(flag_bits, hashes)

      tree.root.reverse == @merkle_root
    end
  end
end
