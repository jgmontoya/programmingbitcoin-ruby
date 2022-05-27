module ECC
  class Signature
    attr_reader :r, :s

    def initialize(r, s)
      @r = r
      @s = s
    end

    def to_s
      "Signature(#{@r}, #{s})"
    end
  end
end
