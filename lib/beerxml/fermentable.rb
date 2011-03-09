class Beerxml::Fermentable < Beerxml::Model
  property :name, String, :required => true
  property :type, String, :set => ['Grain', 'Sugar', 'Extract', 'Dry Extract', 'Adjunct'], :required => true
  property :amount, Weight, :required => true
  property :yield, Float, :required => true
  property :color, Float, :required => true

  property :add_after_boil, Boolean, :default => false
  property :origin, String, :length => 512
  property :supplier, String, :length => 512
  property :notes, String, :length => 65535
  property :coarse_fine_diff, Float
  property :moisture, Float
  property :diastatic_power, Float
  property :protein, Float
  property :max_in_batch, Float
  property :recommend_mash, Boolean
  property :ibu_gal_per_lb, Float

  # these are not used in the xml
  property :id, Serial
  belongs_to :recipe, :required => false

  def ppg=(ppg)
    self.yield = Beerxml.round((ppg / 46.214) / 0.01, 2)
  end

  def ppg
    # potential is (yield * 0.001 + 1)
    (self.yield * 0.01) * 46.214
  end

  def total_ppg(efficiency = nil)
    total = ppg * amount.in_pounds.to_f
    total *= (efficiency * 0.01) unless efficiency.nil? || type != 'Grain'
    total
  end

  def total_color
    amount.in_pounds.to_f * color
  end
end
