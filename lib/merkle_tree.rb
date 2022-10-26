require_relative './merkle_helper'
require_relative 'encoding_helper'

class MerkleTree
  include EncodingHelper

  def initialize(total)
    @total = total
    @max_depth = Math.log2(@total).ceil
    @nodes = []
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

  # rubocop:disable Metrics//PerceivedComplexity
  def populate_tree(flag_bits, hashes)
    until root
      if leaf?
        handle_leaf(flag_bits, hashes)
      else
        left_hash = get_left_node
        if left_hash.nil?
          handle_left(flag_bits, hashes)
        elsif right_exists?
          right_hash = get_right_node
          handle_right(left_hash, right_hash)
        else
          set_current_node(MerkleHelper.merkle_parent(left_hash, left_hash))
          up
        end
      end
    end

    raise "Not all hashes consumed (#{hashes.size})" if hashes.size.positive?
    raise 'Not all flag bits consumed' unless flag_bits.all?(0)
  end
  # rubocop:enable Metrics//PerceivedComplexity

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
    if flag_bits.shift.zero?
      set_current_node(hashes.shift)
      up
    else
      left
    end
  end

  def handle_leaf(flag_bits, hashes)
    flag_bits.shift
    set_current_node(hashes.shift)
    up
  end

  def handle_right(left_hash, right_hash)
    if right_hash.nil?
      right
    else
      set_current_node(MerkleHelper.merkle_parent(left_hash, right_hash))
      up
    end
  end

  def build_nodes
    (0..@max_depth).step do |depth|
      num_items = (@total.to_f / 2**(@max_depth - depth)).ceil
      level_hashes = [nil] * num_items
      @nodes << level_hashes
    end
  end
end
