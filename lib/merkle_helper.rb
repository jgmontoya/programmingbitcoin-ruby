require_relative 'hash_helper'

module MerkleHelper
  def self.merkle_parent(hash1, hash2)
    HashHelper.hash256(hash1 + hash2)
  end

  def self.merkle_parent_level(hashes)
    raise ArgumentError, "List of hashes can't be of size one" if hashes.size == 1

    if hashes.size.odd?
      hashes << hashes.last
    end

    parent_level = []

    (0...hashes.size).step(2) do |i|
      parent_level << merkle_parent(hashes[i], hashes[i + 1])
    end
    parent_level
  end

  def self.merkle_root(hashes)
    current_hashes = hashes

    until current_hashes.size == 1
      current_hashes = merkle_parent_level(current_hashes)
    end
    current_hashes.first
  end
end
