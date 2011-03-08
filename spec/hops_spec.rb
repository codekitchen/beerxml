require "#{File.dirname(__FILE__)}/spec_helper"

require 'beerxml/unit'

describe Beerxml::Hop do
  describe "IBUs" do
    it "should calculate IBUs using the Tinseth formula" do
      hop = Beerxml::Hop.new(:name => "Cascade",
                             :alpha => 6,
                             :amount => U('0.5 oz'),
                             :use => 'Boil',
                             :time => 20)
      hop.should be_valid
      hop.tinseth(1.065, 5.5).should == 5
      # tinseth by default
      hop.ibus(1.065, 5.5).should == 5

      hop2 = Beerxml::Hop.new(:name => 'Goldings',
                              :alpha => 5,
                              :amount => U(4.5, 'oz'),
                              :use => 'Boil',
                              :time => 60)
      hop2.should be_valid
      hop2.ibus(1.081, 11).should == 27
    end
  end
end
