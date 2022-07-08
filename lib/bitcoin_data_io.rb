require 'forwardable'

class BitcoinDataIO
  extend Forwardable

  def_delegators :@io, :read, :rewind

  def initialize(_io)
    @io = _io
  end

  def read_le(_length)
    @io.read(_length).reverse
  end

  def read_le_int16
    @io.read(2).unpack1('v')
  end

  def read_le_int32
    @io.read(4).unpack1('V')
  end

  def read_le_int64
    @io.read(8).unpack1('Q<')
  end

  def read_varint
    r = @io.read(1).unpack1('C')

    case r
    when 0xfd
      read_le_int16
    when 0xfe
      read_le_int32
    when 0xff
      read_le_int64
    else
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
