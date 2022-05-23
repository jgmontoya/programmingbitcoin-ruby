module ECC
  class FieldElement
    attr_reader :num, :prime

    def initialize(num, prime)
      if num >= prime || num.negative?
        raise ArgumentError.new "Num #{num} not in field of range 0 to #{prime - 1}."
      end

      @num = num
      @prime = prime
    end

    def to_s
      "FieldElement_#{@prime}(#{@num})"
    end

    def inspect
      to_s
    end

    def ==(other)
      return false unless other

      @num == other.num && @prime == other.prime
    end

    def +(other)
      check_prime_for('add', other)

      num = (@num + other.num) % @prime
      self.class.new(num, @prime)
    end

    def -(other)
      check_prime_for('subtract', other)

      num = (@num - other.num) % @prime
      self.class.new(num, @prime)
    end

    def *(other)
      if other.is_a?(FieldElement)
        check_prime_for('multiply', other)

        num = (@num * other.num) % @prime
        self.class.new(num, @prime)
      else
        num = (@num * other) % @prime
        self.class.new(num, @prime)
      end
    end

    def **(exponent)
      positive_exponent = exponent % (@prime - 1)
      num = @num.pow(positive_exponent, @prime)
      self.class.new(num, @prime)
    end

    def /(other)
      check_prime_for('divide', other)

      inverse_other = other**-1
      self * inverse_other
    end

    private

    def coerce(something)
      [self, something]
    end

    def check_prime_for(operation, other)
      if @prime != other.prime
        raise TypeError.new "Cannot #{operation} two numbers in different Fields"
      end
    end
  end
end
