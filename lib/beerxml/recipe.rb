class Beerxml::Recipe < Beerxml::Model
  include DataMapper::Resource

  property :name, String, :required => true
  property :type, Enum['Extract', 'Partial Mash', 'All Grain'], :required => true
  # has 1, :style, :required => true
  property :brewer, String, :required => true
  property :batch_size, Float, :required => true
  property :boil_size, Float, :required => true
  property :boil_time, Integer, :required => true
  property :efficiency, Float
  validates_presence_of :efficiency, :if => proc { |t| t.type != 'Extract' }

  has n, :hops
  has n, :fermentables
  # has n, :miscs
  # has n, :yeasts
  # has n, :waters

  property :asst_brewer, String
  property :notes, String, :length => 65535
  property :taste_notes, String, :length => 65535
  property :taste_rating, Float
  property :og, Float
  property :fg, Float
  property :fermentation_stages, Integer
  property :primary_age, Integer
  property :primary_temp, Float
  property :secondary_age, Integer
  property :secondary_temp, Float
  property :tertiary_age, Integer
  property :tertiary_temp, Float
  property :age, Integer
  property :age_temp, Float
  property :date, String
  property :carbonation, Float
  property :forced_carbonation, Boolean
  property :priming_sugar_name, String
  property :carbonation_temp, Float
  property :priming_sugar_equiv, Float
  property :keg_priming_factor, Float
  # has 1, :equipment
  # has 1, :mash
  # validates_presence_of :mash, :if => proc { |t| t.type != 'Extract' }

  # these are not used in the xml
  property :id, Serial
end
