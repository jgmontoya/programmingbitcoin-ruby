require_relative 's256_field.rb'
require_relative 'point.rb'
require_relative 'constants.rb'

module ECC
  class S256Point < Point

    def initialize(x, y, a = 0, b = 7)
      a = S256Field.new(ECC::A)
      b = S256Field.new(ECC::B)

      if x.is_a?(Integer)
        x = S256Field.new(x)
        y = S256Field.new(y)
        super(x, y, a, b)
      else
        super(x, y, a, b)
      end
    end

    def to_s
      return "Point(infinity)_S256Field" if @x.nil? && @y.nil?

      "Point(#{@x}, #{@y})_S256Field"
    end

    def *(coef)
      # to add eficiency, mod by order of group N
      coef = coef % ECC::N
      super
    end

    def self.G
      S256Point.new(ECC::G_X, ECC::G_Y)
    end

    def verify(z, sig)
      s_inv = sig.s.pow(ECC::N - 2, ECC::N)
      u = z * s_inv % ECC::N
      v = sig.r * s_inv % ECC::N
      total = self.class.G.*(u) + self.*(v)
      return total.x.num == sig.r
    end
  end
end
