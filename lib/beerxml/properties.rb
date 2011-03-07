require 'beerxml/primitives'

# Custom DM property types for the various BeerXML data types.
module Beerxml::Properties

  # Represents a weight. Default scale is kilograms, since that's what
  # BeerXML uses. But can handle conversion/display of other units.
  class Weight < DataMapper::Property::Float
    def load(value)
      return if value.nil?
      Beerxml::Primitives::Weight.new(value, 'kg')
    end

    def dump(value)
      return if value.nil?
      value.in('kg').to_f
    end

    def typecast_to_primitive(value)
      load(value)
    end
  end

  # Appendix A: http://www.beerxml.com/beerxml.htm
  # "all fields that are defined for display only may also use a unit
  # tag after them". For example “3.45 gal” is an acceptable value.
  class DisplayWeight < Weight
  end

end
