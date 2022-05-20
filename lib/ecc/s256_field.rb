require_relative 'field_element.rb'
require_relative 'constants.rb'

module ECC
  class S256Field < FieldElement

    def initialize(num, prime = ECC::P)
      super(num, prime)
    end

    def to_s
      @num.to_s.rjust(64, '0')
    end
  end
end
