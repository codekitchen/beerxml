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

  # returns a hash of { style_name => style }
  def self.predefined(style_guide)
    @predefined_styles[style_guide.to_s] ||= begin
      doc_path = File.expand_path(
        File.dirname(__FILE__)+"/../../data/styles/#{style_guide}.xml")
      styles = Beerxml.parse(File.open(doc_path))
      styles.inject({}) { |h, style| h[style.name] = style; h }
    end
  end
end
