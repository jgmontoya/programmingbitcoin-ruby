require_relative 'field_element'
require_relative 'secp256k1_constants'

module ECC
  class S256Field < FieldElement
    def initialize(num, prime = Secp256k1Constants::P)
      super(num, prime)
    end

    def to_s
      @num.to_s.rjust(64, '0')
    end

    def sqrt
      self**((@prime + 1) / 4)
    end
  end
end
