require_relative 'field_element.rb'
require_relative 'secp256k1_constants.rb'

module ECC
  class S256Field < FieldElement

    def initialize(num, prime = Secp256k1Constants::P)
      super(num, prime)
    end

    def to_s
      @num.to_s.rjust(64, '0')
    end
  end
end
