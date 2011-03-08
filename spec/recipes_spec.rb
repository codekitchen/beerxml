require "#{File.dirname(__FILE__)}/spec_helper"

describe Beerxml::Recipe do
  it "should calculate IBUs using the tinseth method" do
    recipe = Beerxml::Recipe.new.from_xml(read_xml("recipes").root.children[1])
    recipe.should be_valid
    recipe.ibus.round.should == 32
  end

  it "should calculate the OG for an all grain batch" do
    recipe = Beerxml::Recipe.new.from_xml(read_xml("recipes").root.children[1])
    recipe.should be_valid
    recipe.calculate_og.should == 1.056
  end
end
