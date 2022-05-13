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

    def !=(other)
      return true unless other

      @a != other.a || @b != other.b || @x != other.x || @y != other.y
    end

    def to_s 
      "x:#{@x || 'nil'}, y:#{@y || 'nil'}, a:#{@a}, b:#{@b}"
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

    private

    def add_different_points(other)
      slope = (other.y - @y).to_f/(other.x - @x)
      x = slope**2 - @x - other.x
      y = slope * (@x - x) - @y
      self.class.new(x, y, @a, @b)
    end

    def add_same_points
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
