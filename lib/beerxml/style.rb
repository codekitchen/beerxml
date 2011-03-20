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

  # these are not used in the xml
  property :id, Serial
  belongs_to :recipe, :required => false

  def range(attr)
    case attr.to_s
    when 'og', 'fg', 'ibu', 'color', 'carb', 'abv'
      (send("#{attr}_min") .. send("#{attr}_max"))
    else
      raise ArgumentError, "Invalid attribute"
    end
  end

  @predefined_styles = {}

  # returns an array of Style objects
  # both the array and the styles in the array are frozen, so make sure to .dup
  # the object if you want to modify it.
  def self.predefined(style_guide)
    @predefined_styles[style_guide.to_s] ||= begin
      doc_path = File.expand_path(
        File.dirname(__FILE__)+"/../../data/styles/#{style_guide}.xml")
      styles = Beerxml.parse(File.open(doc_path)).map { |s| s.freeze }.freeze
    end
  end

  # naive ranking, treats all values with equal weight and just measures the
  # distance from the middle of the road for each value.
  def match_ranking(og, fg, abv, ibu, color)
    rank_attr(og, og_min, og_max) +
      rank_attr(fg, fg_min, fg_max) +
      rank_attr(abv, abv_min, abv_max) +
      rank_attr(ibu, ibu_min, ibu_max) +
      rank_attr(color, color_min, color_max)
  end

  protected

  def rank_attr(val, min, max)
    return Infinity if max.nil? || min.nil? || max == '' || min == ''
    range = max - min
    mid = max - (range / 2)
    (val - mid).abs / range
  end
end
