require "#{File.dirname(__FILE__)}/spec_helper"

describe "beerxml.com examples" do
  it "should parse the first recipe and its hops" do
    recipe = Beerxml::Recipe.new.from_xml(read_xml("recipes").root.children[1])

    recipe.name.should == "Burton Ale"
    recipe.should be_valid

    recipe.hops.length.should == 4
    hop = recipe.hops.first
    hop.should be_a(Beerxml::Hop)
    hop.name.should == "Goldings, East Kent"
    hop.time.should == 60
    hop.type.should == "Aroma"
    hop.should be_valid
    hop.alpha.should == 5.5
  end

  it "should survive the round trip" do
    hop = Beerxml::Hop.new.from_xml(read_xml("hops").root.children[1])
    hop.should be_valid
    xml = hop.to_xml
    hop2 = Beerxml::Hop.new.from_xml(Nokogiri::XML(xml).root)
    hop2.should be_valid
    hop2.attributes.should == hop.attributes
  end

  def assert_hops(hops)
    hops.size.should == 5
    hops.each { |h| h.should(be_a(Beerxml::Hop)) && h.should(be_valid) }
    hops.map(&:name).should == ["Cascade", "Galena", "Goldings, B.C.", "Northern Brewer", "Tettnang"]
  end

  describe "auto-discovery of root node types" do
    it "should discover singular nodes" do
      hop = Beerxml::Model.from_xml(read_xml("hops").root.children[1])
      hop.should be_a(Beerxml::Hop)
      hop.should be_valid
      hop.name.should == "Cascade"
    end

    it "should discover plural nodes" do
      hops = Beerxml::Model.from_xml(read_xml("hops").root)
      assert_hops(hops)
    end
  end

  it "should parse given a string or IO" do
    hops = Beerxml.parse(File.read(filename("hops")))
    assert_hops(hops)
    hops = Beerxml.parse(File.open(filename("hops"), "rb"))
    assert_hops(hops)
  end

  describe "sanity checks" do
    def check_parse(klass, file, node, attrs)
      model = klass.new.from_xml(read_xml(file).root.children[node])
      model.should be_valid
      model.attributes.reject { |k,v| v.nil? }.should == attrs
      model
    end
    it "should parse fermentables" do
      check_parse(Beerxml::Fermentable, "grain", 5, {
        :name => 'Munich Malt',
        :type => 'Grain',
        :amount => 0.0,
        :yield => 80.0,
        :color => 9.0,
        :add_after_boil => false,
        :origin => 'Germany',
        :notes => "Malty-sweet flavor characteristic and adds a reddish amber color to the beer.
Does not contribute signficantly to body or head retention.
Use for: Bock, Porter, Marzen, Oktoberfest beers",
        :coarse_fine_diff => 1.3,
        :moisture => 5.0,
        :diastatic_power => 72.0,
        :protein => 11.5,
        :max_in_batch => 80.0,
        :recommend_mash => true,
        :ibu_gal_per_lb => 0.0,
        :supplier => '',
      })
    end
    it "should parse hops" do
      check_parse(Beerxml::Hop, "hops", 7, {
        :name => 'Northern Brewer',
        :origin => 'Germany',
        :alpha => 8.5,
        :amount => 0.0,
        :use => 'Boil',
        :time => 0.0,
        :notes => %{Also called Hallertauer Northern Brewers
Use for: Bittering and finishing both ales and lagers of all kinds
Aroma: Fine, dry, clean bittering hop.  Unique flavor.
Substitute: Hallertauer Mittelfrueh, Hallertauer
Examples: Anchor Steam, Old Peculiar, },
        :type => 'Both',
        :form => 'Pellet',
        :beta => 4.0,
        :hsi => 35.0,
      })
    end
    it "should parse yeasts" do
      check_parse(Beerxml::Yeast, "yeast", 3, {
        :name => 'European Ale',
        :type => 'Ale',
        :form => 'Liquid',
        :amount => 0.035,
        :amount_is_weight => false,
        :laboratory => 'White Labs',
        :product_id => 'WLP011',
        :min_temperature => 18.3,
        :max_temperature => 21.1,
        :flocculation => 'Medium',
        :attenuation => 67.5,
        :notes => "Malty, Northern European ale yeast.  Low ester production, low sulfer, gives a clean profile.  Low attenuation contributes to malty taste.",
        :best_for => "Alt, Kolsch, malty English Ales, Fruit beers",
        :max_reuse => 5,
        :times_cultured => 0,
        :add_to_secondary => false,
      })
    end
    it "should parse recipes" do
      recipe = check_parse(Beerxml::Recipe, "recipes", 3, {
        :name => 'Dry Stout',
        :type => 'All Grain',
        :brewer => 'Brad Smith',
        :asst_brewer => '',
        :batch_size => 18.92716800,
        :boil_size => 20.81988500,
        :boil_time => 60,
        :efficiency => 72.0,
        :notes => %{A very simple all grain beer that produces a great Guiness-style taste every time.  So light in body that I have even made black and tans with it using a full body pale ale in the bottom of the glass.},
        :taste_notes => %{One of my favorite stock beers - I always keep a keg on hand.  Rich flavored dry Irish Stout that is very simple to make.  Perfect every time!},
        :taste_rating => 44.0,
        :og => 1.038,
        :fg => 1.012,
        :carbonation => 2.3,
        :fermentation_stages => 2,
        :primary_age => 4,
        :primary_temp => 20.000,
        :secondary_age => 7,
        :secondary_temp => 20.000,
        :tertiary_age => 0,
        :age => 7,
        :age_temp => 5.000,
        :date => '4/1/2003',
      })
      recipe.hops.map(&:attributes).should == [
        :name => 'Goldings, East Kent',
        :origin => 'United Kingdom',
        :alpha => 5.0,
        :amount => 0.0637860,
        :use => 'Boil',
        :time => 60,
        :notes => %{Used For: General purpose hops for bittering/finishing all British Ales
Aroma: Floral, aromatic, earthy, slightly sweet spicy flavor
Substitutes: Fuggles, BC Goldings
Examples: Bass Pale Ale, Fullers ESB, Samual Smith's Pale Ale
},
        :type => 'Aroma',
        :form => 'Pellet',
        :beta => 3.5,
        :hsi => 35.0,
        :recipe_id => nil,
      ]
      recipe.fermentables.map(&:name).should == ['Pale Malt (2 Row) UK', 'Barley, Flaked', 'Black Barley (Stout)']
    end
  end
end
