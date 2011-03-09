require "#{File.dirname(__FILE__)}/spec_helper"

describe "dumping" do
  describe "sanity checks" do
    it "should dump hops" do
      model = Beerxml::Hop.new({
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
      model.should be_valid
      xml = model.to_beerxml.root
      (xml>'NAME').text.should == 'Northern Brewer'
      (xml>'ORIGIN').text.should == 'Germany'
      (xml>'ALPHA').text.should == '8.5'
      (xml>'AMOUNT').text.should == '0.0'
      (xml>'USE').text.should == 'Boil'
      (xml>'TIME').text.should == '0.0'
      (xml>'TYPE').text.should == 'Both'
      (xml>'FORM').text.should == 'Pellet'
      (xml>'BETA').text.should == '4.0'
      (xml>'HSI').text.should == '35.0'
    end
  end
end
