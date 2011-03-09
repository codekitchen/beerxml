class Beerxml::Recipe < Beerxml::Model
  include DataMapper::Resource

  property :name, String, :required => true
  property :type, Enum['Extract', 'Partial Mash', 'All Grain'], :required => true
  # has 1, :style, :required => true
  property :brewer, String, :required => true
  property :batch_size, Volume, :required => true
  property :boil_size, Volume, :required => true
  property :boil_time, Time, :required => true
  property :efficiency, Float
  validates_presence_of :efficiency, :if => proc { |t| t.type != 'Extract' }

  has n, :hops
  has n, :fermentables
  # has n, :miscs
  has n, :yeasts
  # has n, :waters

  property :asst_brewer, String
  property :notes, String, :length => 65535
  property :taste_notes, String, :length => 65535
  property :taste_rating, Float
  property :og, Float
  property :fg, Float
  property :fermentation_stages, Integer
  property :primary_age, TimeInDays
  property :primary_temp, Temperature
  property :secondary_age, TimeInDays
  property :secondary_temp, Temperature
  property :tertiary_age, TimeInDays
  property :tertiary_temp, Temperature
  property :age, TimeInDays
  property :age_temp, Temperature
  property :date, String
  property :carbonation, Float
  property :forced_carbonation, Boolean
  property :priming_sugar_name, String
  property :carbonation_temp, Temperature
  property :priming_sugar_equiv, Float
  property :keg_priming_factor, Float
  # has 1, :equipment
  # has 1, :mash
  # validates_presence_of :mash, :if => proc { |t| t.type != 'Extract' }

  # these are not used in the xml
  property :id, Serial

  def tinseth
    Beerxml.round(hops.select { |h| h.use == 'Boil' }.inject(0) { |v, h| v + h.tinseth(calculate_og, batch_size) }, 1)
  end
  alias_method :ibus, :tinseth

  def calculate_og
    total_ppg = fermentables.inject(0) { |v, f| v + f.total_ppg(efficiency) }
    og = 1 + ((total_ppg / batch_size.in_gallons.to_f) * 0.001)
    Beerxml.round(og, 3)
  end

  def calculate_fg
    og = calculate_og
    Beerxml.round(og - ((og - 1) * yeasts.first.attenuation * 0.01), 3)
  end

  def color
    color = fermentables.inject(0) { |v, f| v + f.total_color }
    Beerxml.round(1.4922 * ((color / batch_size.in_gallons.to_f) ** 0.6859), 1)
  end
end
