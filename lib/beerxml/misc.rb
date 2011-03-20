class Beerxml::Misc < Beerxml::Model
  property :name, String, :required => true
  property :type, String, :set => ['Spice', 'Fining', 'Water Agent', 'Herb', 'Flavor', 'Other'], :required => true
  property :use, String, :set => ['Boil', 'Mash', 'Primary', 'Secondary', 'Bottling'], :required => true
  property :time, Time, :required => true
  property :amount, AmountIsWeight::VolumeOrWeight, :required => true
  include AmountIsWeight

  property :use_for, String
  property :notes, String, :length => 65535
end
