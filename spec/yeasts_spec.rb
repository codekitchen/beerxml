require "#{File.dirname(__FILE__)}/spec_helper"

describe Beerxml::Yeast do
  it "should parse volume amounts" do
    y = Beerxml::Yeast.new.from_xml(Nokogiri::XML(<<-XML).root)
      <YEAST>
        <AMOUNT>1.0</AMOUNT>
        <AMOUNT_IS_WEIGHT>FALSE</AMOUNT_IS_WEIGHT>
      </YEAST>
        XML
    y.amount.should == U(1.0, 'liters')
    y.amount.type.should == 'volume'
    y.amount_is_weight.should == false
  end
  it "should parse weight amounts" do
    y = Beerxml::Yeast.new.from_xml(Nokogiri::XML(<<-XML).root)
      <YEAST>
        <AMOUNT>1.0</AMOUNT>
        <AMOUNT_IS_WEIGHT>TRUE</AMOUNT_IS_WEIGHT>
      </YEAST>
        XML
    y.amount.should == U(1.0, 'kilograms')
    y.amount.type.should == 'weight'
    y.amount_is_weight.should == true
  end
end
