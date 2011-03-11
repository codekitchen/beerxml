class Beerxml::Style < Beerxml::Model
  property :name, String, :required => true
  property :category, String, :required => true
  property :category_number, String, :required => true
  property :style_letter, String, :required => true
  property :style_guide, String, :required => true
  property :type, String, :set => %w(Lager Ale Mead Wheat Mixed Cider), :required => true
  property :og_min, Float, :required => true
  property :og_max, Float, :required => true
  property :fg_min, Float, :required => true
  property :fg_max, Float, :required => true
  property :ibu_min, Float, :required => true
  property :ibu_max, Float, :required => true
  property :color_min, Float, :required => true
  property :color_max, Float, :required => true

  property :carb_min, Float
  property :carb_max, Float
  property :abv_min, Float
  property :abv_max, Float
  property :notes, String, :length => 65535
  property :profile, String, :length => 65535
  property :ingredients, String, :length => 65535
  property :examples, String, :length => 65535
end
