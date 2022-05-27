require_relative 'field_element'

module ECC
  class Point
    attr_reader :x, :y, :a, :b

    def initialize(x, y, a, b)
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
      check_curve_for(other)

      return other if @x.nil?
      return self if other.x.nil?
      return identity if @x == other.x && @y != other.y

      self != other ? add_different_points(other) : add_same_points
    end

    def *(coef)
      current = self
      result = identity
      while coef != 0
        result += current if coef & 1 == 1
        current += current
        coef >>= 1
      end
      result
    end

    private

    def coerce(something)
      [self, something]
    end

    def add_different_points(other)
      slope = if @x.respond_to?(:to_f)
                (other.y - @y).to_f / (other.x - @x)
              else
                (other.y - @y) / (other.x - @x)
              end

      x = slope**2 - @x - other.x
      y = slope * (@x - x) - @y
      self.class.new(x, y, @a, @b)
    end

    def add_same_points
      return identity if @y == 0 * x

      slope = if @x.respond_to?(:to_f)
                (3 * @x**2 + @a).to_f / (2 * @y)
              else
                (3 * @x**2 + @a) / (2 * @y)
              end

      x = slope**2 - 2 * @x
      y = slope * (@x - x) - @y
      self.class.new(x, y, @a, @b)
    end

    def identity
      @identity ||= self.class.new(nil, nil, @a, @b)
    end

    def check_curve_for(other)
      if @a != other.a || @b != other.b
        raise TypeError.new "Points #{self}, #{other} are not in the same curve"
      end
    end
  end
end
