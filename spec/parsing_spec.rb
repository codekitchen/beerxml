require 'spec/spec_helper'

describe "beerxml.com examples" do
  def read_xml(example)
    Nokogiri::XML(File.read("examples/beerxml.com/#{example}.xml"))
  end

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
end
