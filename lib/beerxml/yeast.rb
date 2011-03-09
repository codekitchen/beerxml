class Beerxml::Yeast < Beerxml::Model
  include DataMapper::Resource

  property :name, String, :required => true
  property :type, String, :set => ['Ale', 'Lager', 'Wheat', 'Wine', 'Champagne'], :required => true
  property :form, String, :set => ['Liquid', 'Dry', 'Slant', 'Culture'], :required => true
  # TODO: sheesh... this can be a Weight instead, if amount_is_weight
  property :amount, Volume, :required => true

  property :amount_is_weight, Boolean
  property :laboratory, String
  property :product_id, String
  property :min_temperature, Temperature
  property :max_temperature, Temperature
  property :flocculation, String, :set => ['Low', 'Medium', 'High', 'Very High']
  property :attenuation, Float
  property :notes, String, :length => 65535
  property :best_for, String
  property :times_cultured, Integer
  property :max_reuse, Integer
  property :add_to_secondary, Boolean

  # these are not used in the xml
  property :id, Serial
  belongs_to :recipe, :required => false
end
