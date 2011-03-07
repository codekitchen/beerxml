require "#{File.dirname(__FILE__)}/spec_helper"

include Beerxml::Primitives

class Float
  def near?(rhs, prec = 0.01)
    self.between?(rhs - prec, rhs + prec)
  end
end

describe "custom properties" do
  describe Weight do
    it "should default to kg" do
      w = Weight.new(153.27)
      w.unit.should == 'kg'
      w.to_f.should == 153.27
    end

    it "should allow constructing with different units" do
      w = Weight.new(53.97, 'oz')
      w.in('kg').should == Weight.new(1.53)
    end

    it "should handle basic conversions" do
      w = Weight.new(1.53)
      w.in('grams').to_f.should == 1530
      w.in('lbs').to_f.should be_near(3.37)
      w.in('lbs').in('ounces').to_f.should be_near(53.97)
      w.in('pounds').in('grams').in('kg').to_f.should be_near(1.53)
    end

    it "should compare between units" do
      w = Weight.new(3.5)
      lbs = w.in('pounds')
      lbs.to_f.should be_near(7.7162)
      w.should == lbs
      w.should == 3.5
      w.in('lbs').should == 7.716
    end

    it "should not compare with strings" do
      w = Weight.new(1)
      proc { w == "5" }.should raise_error(ArgumentError)
    end

    it "should infer in_* methods for defined units" do
      w = Weight.new(1)
      w.in_grams.should == 1000
      w.in_kilograms.should == 1
    end
  end
end
