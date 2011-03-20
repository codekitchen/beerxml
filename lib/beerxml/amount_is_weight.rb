module Beerxml::Model::AmountIsWeight
  # beerxml has these really silly fields where the units can be either weight
  # or volume, depending on a boolean flag in another field.
  class VolumeOrWeight < Beerxml::Properties::Property
    def unit_type
      'volume or weight'
    end

    def base_unit
      'liters'
    end

    def valid_unit_type?(value_type)
      value_type == 'volume' || value_type == 'weight'
    end

    def dump(value)
      return if value.nil?
      value.in(value.type == 'volume' ? 'liters' : 'kilograms').to_f
    end
  end

  def from_xml(*args)
    ret = super
    # fixup if amount_is_weight == true
    if self[:amount_is_weight] == true
      self.amount = U(self.amount.to_f, 'kilograms')
    end
    ret
  end

  def self.included(klass)
    klass.class_eval do
      property :amount_is_weight, ::DataMapper::Property::Boolean
      def amount_is_weight
        self.amount && self.amount.type == 'weight'
      end
    end
  end
end
