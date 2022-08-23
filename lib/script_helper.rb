module ScriptHelper
  def encode_num(num)
    return '' if num.zero?

    int_to_little_endian(num, 1)
  end

  def decode_num(string)
    return 0 if string.empty?

    little_endian_to_int(string)
  end
end
