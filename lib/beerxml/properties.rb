require 'beerxml/unit'

# Custom DM property types for the various BeerXML data types.
module Beerxml::Properties

  # Represents a weight. Default scale is kilograms, since that's what
  # BeerXML uses. But can handle conversion/display of other units.
  class Weight < DataMapper::Property::Float
    def custom? # skip the default Float validations
      true
    end

    def load(value)
      return if value.nil?
      if value.is_a?(Beerxml::Unit)
        raise(ArgumentError, 'Weight required') unless value.weight?
        value
      else
        U(value, 'kg')
      end
    end

    def dump(value)
      return if value.nil?
      value.in('kg').to_f
    end

    def typecast_to_primitive(value)
      load(value)
    end
  end

  class Volume < DataMapper::Property::Float
  end

  class Temperature < DataMapper::Property::Float
  end

  class Time < DataMapper::Property::Float
  end

  class TimeInDays < DataMapper::Property::Float
  end

  class Color < DataMapper::Property::Float
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

  class DisplayColor < Color
  end

end
