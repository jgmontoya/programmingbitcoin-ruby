require_relative 'field_element.rb'

module ECC
  class Point
    attr_reader :x, :y, :a, :b

    def initialize(x,y,a,b)
      @x = x
      @y = y
      @a = a
      @b = b
      return if y.nil? && x.nil?

      if y**2 != x**3 + a * x + b
        raise ArgumentError.new "(#{x},#{y}) is not on the curve"
      end
   end

    def ==(other)
      return false unless other

      @a == other.a && @b == other.b && @x == other.x && @y == other.y
    end

    def to_s
      return "Point(infinity)_#{@a}_#{@b}" if @x.nil? && @y.nil?

      if @x.is_a?(Integer)
        "Point(#{@x}, #{@y})_#{@a}_#{@b}"
      else
        "Point(#{@x.num}, #{@y.num})_#{@a.num}_#{@b.num} FieldElement(#{@x.prime})"
      end
    end

    def +(other)
      if @a != other.a || @b != other.b
        raise TypeError.new "Points #{self}, #{other} are not in the same curve"
      end

      return other if @x.nil?
      return self if other.x.nil?
      return identity if @x == other.x && @y != other.y
      self != other ? add_different_points(other) : add_same_points
    end

    def *(coef)
      current = self
      result = identity
      while coef != 0
        if coef & 1 == 1
          result += current
        end
        current += current
        coef >>= 1
      end
      return result
    end

    private

    def add_different_points(other)
      slope = (other.y - @y) / (other.x - @x)
      x = slope**2 - @x - other.x
      y = slope * (@x - x) - @y
      self.class.new(x, y, @a, @b)
    end

    def add_same_points
     if @x.is_a?(Integer)
      add_same_points_integer
     else
      add_same_points_field
     end
    end

    def add_same_points_field
      if (@y == ECC::FieldElement.new(0, @y.prime) )
        return identity
      end

      slope = (ECC::FieldElement.new(3, @x.prime) * @x ** 2 + @a) / (ECC::FieldElement.new(2, @y.prime) * @y)
      x = slope ** 2 - ECC::FieldElement.new(2, @x.prime) * @x
      y = slope * (@x - x) - @y
      self.class.new(x, y, @a, @b)
    end

    def add_same_points_integer
      return identity if @y == 0
      slope = (3 * @x ** 2 + @a).to_f / (2 * @y)
      x = slope ** 2 - 2 * @x
      y = slope * (@x - x) - @y
      self.class.new(x, y, @a, @b)
    end

    def identity
      @identity ||= self.class.new(nil, nil, @a, @b)
    end
  end
end
