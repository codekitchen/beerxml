module Beerxml
# Unit system with conversions between units of the same type. Very much
# a work in progress.
class Unit
  attr_reader :type, :unit

  Units = {}
  BaseUnits = {}
  UnitToType = {}

  def in(unit, *args)
    self.clone.in!(unit, *args)
  end
  alias_method :to, :in

  def in!(new_unit, *args)
    new_unit = new_unit.to_s
    new_unit_type = UnitToType[new_unit]
    raise(ArgumentError, "Unknown unit: #{new_unit}") if new_unit_type.nil?
    if new_unit_type != type
      raise(ArgumentError, "New unit: #{new_unit} not compatible with current unit: #{unit}")
    end
    @unit = new_unit
    self
  end
  alias_method :to!, :in!
  alias_method :unit=, :in!

  def base_unit
    BaseUnits[type]
  end

  def to_f
    @value * Units[type][unit]
  end

  def initialize(amount, unit = nil)
    if amount.is_a?(Unit)
      if unit
        amount = amount.to(unit).to_f
      else
        amount, unit = amount.to_f, amount.unit
      end
    elsif !unit
      amount, unit = amount.to_s.split(/\s+/, 2)
    end
    unit = unit.to_s

    @type = UnitToType[unit]
    self.unit = unit
    @value = Float(amount) / Units[type][unit]
  end

  def is?(unit)
    self.unit == unit ||
      (UnitToType[self.unit] == UnitToType[unit] &&
       Units[type][self.unit] == Units[type][unit])
  end

  def self.add_type(type, base_unit_name, *aliases)
    Units[type] = {}
    Units[type][base_unit_name] = 1.0
    UnitToType[base_unit_name] = type
    BaseUnits[type] = base_unit_name
    aliases.each { |a| add_alias(type, base_unit_name, a) }
  end
  def self.add(type, factor, name, *aliases)
    Units[type][name] = factor.to_f
    aliases.each { |a| add_alias(type, name, a) }
    UnitToType[name] = type
  end
  def self.add_alias(type, name, new_alias)
    base = Units[type][name]
    raise(ArgumentError, "Unknown base: #{name}") unless base
    Units[type][new_alias] = base
    UnitToType[new_alias] = type
  end

  def ==(rhs)
    # TODO: hard-coding this precision stinks...
    if rhs.is_a?(self.class)
      rhs = rhs.in(base_unit)
      @value.between?(rhs.to_f - 0.01, rhs.to_f + 0.01)
    elsif rhs.is_a?(Numeric)
      to_f.between?(rhs.to_f - 0.01, rhs.to_f + 0.01)
    else
      raise ArgumentError, "#{rhs.inspect} is not a #{self.class.name}"
    end
  end

  def method_missing(meth, *a, &b)
    if meth.to_s =~ %r{\A(to|in)_([^!]+)(!)?\z}
      send($3 ? :in! : :in, $2)
    else
      super
    end
  end

  def inspect
    "[#{to_f} #{unit}]"
  end

  # Assumes earth gravity ;)
  module Weight
    def self.included(k)
      k.add_type('weight', 'kg', 'kilogram', 'kilograms')
      k.add('weight', 1000, 'g', 'gram', 'grams')
      k.add('weight', 2.204622, 'lb', 'pound', 'pounds', 'lbs')
      k.add('weight', 35.273961, 'oz', 'ounce', 'ounces')
    end
  end
  include Weight

  module Volume
    def self.included(k)
      k.add_type('volume', 'liters', 'l', 'liter')
      k.add('volume', 0.26417, 'gallons', 'gallon')
    end
  end
  include Volume

  module Time
    def self.included(k)
      k.add_type('time', 'day', 'days')
      k.add('time', 24, 'hour', 'hours')
      k.add('time', 1440, 'minute', 'minutes')
    end
  end
  include Time

  module Temperature
    def self.included(k)
      k.add_type('temperature', 'c', 'C', 'celsius')
      # k.add('temperature', proc {}, 'f', 'F', 'fahrenheit')
    end
  end
  include Temperature

  def self.apply_to_numeric!
    Beerxml::Unit::UnitToType.each do |unit, v|
      Numeric.class_eval(<<-METHOD, __FILE__, __LINE__+1)
      def #{unit}
        Beerxml::Unit.new(self, #{unit.inspect})
      end
      METHOD
    end
  end
end
end

def U(*a)
  Beerxml::Unit.new(*a)
end
