require_relative 's256_field.rb'
require_relative 'point.rb'
require_relative 'secp256k1_constants.rb'

module ECC
  class S256Point < Point

    def initialize(x, y, a = 0, b = 7)
      a = S256Field.new(Secp256k1Constants::A)
      b = S256Field.new(Secp256k1Constants::B)

      if x.is_a?(Integer)
        x = S256Field.new(x)
        y = S256Field.new(y)
        super(x, y, a, b)
      else
        super(x, y, a, b)
      end
    end

    G = S256Point.new(Secp256k1Constants::G_X, Secp256k1Constants::G_Y)

    def to_s
      return "Point(infinity)_S256Field" if @x.nil? && @y.nil?

      "Point(#{@x}, #{@y})_S256Field"
    end

    def *(coef)
      coef = coef % Secp256k1Constants::N
      super(coef)
    end

    def self.G
      S256Point.new(Secp256k1Constants::G_X, Secp256k1Constants::G_Y)
    end

    def verify(z, signature)
      s_inv = signature.s.pow(Secp256k1Constants::N - 2, Secp256k1Constants::N)
      u = z * s_inv % Secp256k1Constants::N
      v = signature.r * s_inv % Secp256k1Constants::N
      random_target = (u * self.class::G + v * self).x.num
      random_target == signature.r
    end
  end
end
