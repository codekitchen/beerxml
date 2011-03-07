class Beerxml::Hop < Beerxml::Model
  property :name, String, :required => true
  property :alpha, Float, :required => true
  property :amount, Float, :required => true
  property :use, Enum['Boil', 'Dry Hop', 'Mash', 'First Wort', 'Aroma'], :required => true
  property :time, Integer, :required => true

  property :notes, String, :length => 65535
  property :type, Enum[nil, 'Bittering', 'Aroma', 'Both']
  property :form, Enum[nil, 'Pellet', 'Plug', 'Leaf']
  property :beta, Float
  property :hsi, Float
  property :origin, String, :length => 512
  property :substitutes, String, :length => 512
  property :humulene, String, :length => 512
  property :caryophyllene, String, :length => 512
  property :cohumulone, String, :length => 512
  property :myrcene, String, :length => 512

  # these are not used in the xml
  property :id, Serial
  belongs_to :recipe, :required => false
end
