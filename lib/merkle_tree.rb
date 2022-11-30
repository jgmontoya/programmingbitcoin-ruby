require_relative './merkle_helper'
require_relative 'encoding_helper'

class MerkleTree
  include EncodingHelper

  def initialize(total)
    @total = total
    @max_depth = Math.log2(@total).ceil
    @current_index = 0
    @current_depth = 0

    build_nodes
  end

  attr_reader :nodes, :current_index, :current_depth, :total, :max_depth

  def to_s
    result = []
    @nodes.each do |level|
      items = []
      level.each do |hash|
        items << (hash.nil? ? "None" : bytes_to_hex(hash)[...8].to_s)
      end
      result << items.join(', ')
    end
    result.join("\n")
  end

  def populate_tree(flag_bits, hashes)
    until root
      next handle_leaf(flag_bits, hashes) if leaf?

      left_hash = get_left_node
      next handle_left(flag_bits, hashes) if left_hash.nil?
      next handle_right(left_hash, get_right_node) if right_exists?

      set_current_node(MerkleHelper.merkle_parent(left_hash, left_hash))
      up
    end

    raise "Not all hashes consumed (#{hashes.size})" if hashes.size.positive?
    raise 'Not all flag bits consumed' unless flag_bits.all?(0)
  end

  def root
    @nodes[0][0]
  end

  private

  def up
    @current_depth -= 1
    @current_index /= 2
  end

  def left
    @current_depth += 1
    @current_index *= 2
  end

  def right
    @current_depth += 1
    @current_index = @current_index * 2 + 1
  end

  def set_current_node(value)
    @nodes[@current_depth][@current_index] = value
  end

  def get_current_node
    @nodes[@current_depth][@current_index]
  end

  def get_left_node
    @nodes[@current_depth + 1][@current_index * 2]
  end

  def get_right_node
    @nodes[@current_depth + 1][@current_index * 2 + 1]
  end

  def leaf?
    @current_depth == @max_depth
  end

  def right_exists?
    @nodes[@current_depth + 1].size > @current_index * 2 + 1
  end

  def handle_left(flag_bits, hashes)
    return left unless flag_bits.shift.zero?

    set_current_node(hashes.shift)
    up
  end

  def handle_right(left_hash, right_hash)
    return right if right_hash.nil?

    set_current_node(MerkleHelper.merkle_parent(left_hash, right_hash))
    up
  end

  def handle_leaf(flag_bits, hashes)
    flag_bits.shift
    set_current_node(hashes.shift)
    up
  end

  def build_nodes
    @nodes = (0..@max_depth).map do |depth|
      num_items = (@total.to_f / 2**(max_depth - depth)).ceil
      [nil] * num_items
    end
  end
end
