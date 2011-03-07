module Beerxml::Primitives
  class Weight
    Base = 'kg'
    Units = {
      'kg'        => 1.0,
      'g'         => 1000.0,
      'lb'        => 2.204622,
      'oz'        => 35.273961,
    }

    Aliases = {
      'kg' => %w(kilogram kilograms),
      'g' => %w(gram grams),
      'lb' => %w(pound pounds lbs),
      'oz' => %w(ounce ounces),
    }
    # Pre-compute aliases
    Aliases.each { |o, as| as.each { |a| Units[a] = Units[o] } }

    attr_accessor :unit
    attr_reader :value

    def initialize(initial, unit = Base)
      @unit = unit
      if @unit == Base
        @value = Float(initial)
      else
        @value = Float(initial) / Units[@unit]
      end
    end

    def in(unit)
      ret = self.dup
      ret.instance_variable_set(:@value, self.value)
      ret.unit = unit
      ret
    end

    def method_missing(meth, *a, &b)
      if meth.to_s =~ %r{\Ain_(.*)\z}
        send(:in, $1)
      else
        super
      end
    end

    def ==(rhs)
      # TODO: hard-coding this precision stinks...
      if rhs.is_a?(self.class)
        self.value.between?(rhs.value - 0.01, rhs.value + 0.01)
      elsif rhs.is_a?(Numeric)
        self.to_f.between?(rhs.to_f - 0.01, rhs.to_f + 0.01)
      else
        raise ArgumentError, "#{rhs.inspect} is not a #{self.class.name}"
      end
    end

    def to_f
      value = self.value
      if self.unit != Base
        value = value * Units[self.unit]
      end
      value
    end

    def inspect
      "#{to_s}kg"
    end

    def to_s # always prints in kg...
      value.to_s
    end
  end
end
