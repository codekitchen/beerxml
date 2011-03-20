require 'beerxml/unit'

# Custom DM property types for the various BeerXML data types.
module Beerxml::Properties

  class Property < DataMapper::Property::Float
    def custom?
      true
    end

    def valid_unit_type?(value_type)
      value_type == unit_type
    end

    def primitive?(value)
      value.is_a?(Beerxml::Unit) && valid_unit_type?(value.type)
    end

    def load(value)
      return if value.nil?
      if value.is_a?(Beerxml::Unit)
        raise(ArgumentError, "#{value.inspect} is not a #{unit_type}") unless valid_unit_type?(value.type)
        value
      else
        U(value, base_unit)
      end
    end

    def dump(value)
      return if value.nil?
      value.in(base_unit).to_f
    end

    def typecast_to_primitive(value)
      load(value)
    end
  end

  # Represents a weight. Default scale is kilograms, since that's what
  # BeerXML uses. But can handle conversion/display of other units.
  class Weight < Property
    def unit_type
      'weight'
    end
    def base_unit
      'kilograms'
    end
  end

  # A volume, in liters.
  class Volume < Property
    def unit_type
      'volume'
    end
    def base_unit
      'liters'
    end
  end

  # A temperature, in deg C.
  class Temperature < Property
    def unit_type
      'temperature'
    end
    def base_unit
      'C'
    end
  end

  # A time, in minutes.
  class Time < Property
    def unit_type
      'time'
    end
    def base_unit
      'minutes'
    end
  end

  # Time, but in days.
  class TimeInDays < Time
    def base_unit
      'days'
    end
  end

  # Appendix A: http://www.beerxml.com/beerxml.htm
  # "all fields that are defined for display only may also use a unit
  # tag after them". For example “3.45 gal” is an acceptable value.
  class DisplayWeight < Weight
  end

  class DisplayVolume < Volume
  end

  class DisplayTemperature < Temperature
  end

  class DisplayTime < Time
  end
end
