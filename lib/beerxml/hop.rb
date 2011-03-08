class Beerxml::Hop < Beerxml::Model
  property :name, String, :required => true
  property :alpha, Float, :required => true
  property :amount, Weight, :required => true
  property :use, Enum['Boil', 'Dry Hop', 'Mash', 'First Wort', 'Aroma'], :required => true
  property :time, Time, :required => true

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

  def tinseth(post_boil_og, batch_size) # batch size is gallons or Unit
    bigness = 1.65 * 0.000125**(post_boil_og - 1)
    boil_factor = (1 - 2.72 ** (-0.04 * time.in_minutes.to_f)) / 4.15
    utilization = bigness * boil_factor
    ibus = utilization * (aau * 0.01 * 7490) / U(batch_size, 'gallons').to_f
    Beerxml.round(ibus, 1)
  end
  alias_method :ibus, :tinseth

  def aau
    alpha * amount.in('ounces').to_f
  end
end
