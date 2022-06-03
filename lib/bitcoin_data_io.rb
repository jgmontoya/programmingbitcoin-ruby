require 'forwardable'

class BitcoinDataIO
  extend Forwardable

  def_delegators :@io, :gets, :rewind

  def initialize(_io)
    @io = _io
  end

  def gets_le(_length)
    @io.gets(_length).reverse
  end

  def get_le_short
    @io.gets(2).unpack1('v')
  end

  def get_le_integer
    @io.gets(4).unpack1('V')
  end

  def get_le_long
    @io.gets(8).unpack1('Q<')
  end

  def get_varint
    r = @io.gets(1).unpack1('C')

    case r
    when 0xfd # 0xfd means the next two bytes are the number
      get_le_short
    when 0xfe # 0xfe means the next four bytes are the number
      get_le_integer
    when 0xff # 0xff means the next eight bytes are the number
      get_le_long
    else      # anything else is just the integer
      r
    end
  end
end

module Kernel
  def BitcoinDataIO(_io) # rubocop:disable Naming/MethodName
    return _io if _io.is_a? BitcoinDataIO

    ::BitcoinDataIO.new(_io)
  end
end
