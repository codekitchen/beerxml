require "#{File.dirname(__FILE__)}/spec_helper"

describe Beerxml::Style do
  it "should have predefined BJCP styles" do
    styles = Beerxml::Style.predefined(:bjcp)
    style = styles['Cream Ale']
    style.should be_valid
    style.category_number.should == '6'
    style.style_letter.should == 'A'
    style.range(:og).should == (1.042 .. 1.055)
  end
end
