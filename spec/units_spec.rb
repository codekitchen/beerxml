require "#{File.dirname(__FILE__)}/spec_helper"

class Float
  def near?(rhs, prec = 0.01)
    self.between?(rhs - prec, rhs + prec)
  end
end

describe Beerxml::Unit do
  it "should allow constructing with base units" do
    w = U('153.27 kg')
    w.unit.should == 'kg'
    w.is?('kg').should be_true
    w.is?('kilograms').should be_true
    w.is?('g').should be_false
    w.to_f.should == 153.27
    w.should == 153.27
    w.should == U(153.27, 'kg')
    w.should == U('153.27', 'kg')
  end

  it "should reject unknown units" do
    proc { U('153') }.should raise_error(ArgumentError)
    proc { U('153 glorbs') }.should raise_error(ArgumentError)
    proc { U(153, 'glorbs') }.should raise_error(ArgumentError)
  end

  it "should require an amount" do
    proc { U('kg') }.should raise_error(ArgumentError)
    proc { U('hai kg') }.should raise_error(ArgumentError)
    proc { U('hai', 'kg') }.should raise_error(ArgumentError)
  end

  it "should allow symbols for units" do
    U(2, :kg).should == U(2, 'kilograms')
  end

  it "should allow constructing with different units" do
    w = U(53.97, 'oz')
    w.in('kg').should == U(1.53, 'kg')
    w.should == U('53.97 oz')
  end

  it "should allow constructing from another compatible Unit object" do
    w = U(53.97, 'oz')
    w2 = U(w) # defaults to oz, same units as copying object
    w3 = U(w, 'kg')
    w.should == w2
    w.should == w3
    w2.should == w3
    w2.should == 53.97
    w3.should == 1.53
  end

  describe "equality" do
    it "should compare between units" do
      w = U(3.5, 'kg')
      lbs = w.in('pounds')
      lbs.to_f.should be_near(7.7162)
      w.should == lbs
      w.should == 3.5
      w.in('lbs').should == 7.716
    end

    it "should not compare with strings" do
      w = U(1, 'kg')
      proc { w == "5" }.should raise_error(ArgumentError)
    end

    it "should not allow equality between incompatible units" do
      w = U(53.97, 'oz')
      v = U(2, 'gallons')
      proc { w == v }.should raise_error(ArgumentError)
    end
  end

  it "should infer in_* methods for defined units" do
    w = U(1, 'kg')
    w.in_grams.should == 1000
    w.in_kilograms.should == 1
  end

  describe "changing units in place" do
    it "should allow changing units with attr writer" do
      w = U(1, 'kg')
      w.to_f.should == 1
      w.unit = 'g'
      w.to_f.should == 1000
    end

    it "should not allow changing to an unknown unit" do
      w = U(1, 'kg')
      proc { w.in!('blorg') }.should raise_error(ArgumentError)
    end

    it "should not allow changing to an incompatible unit" do
      w = U(1, 'kg')
      proc { w.in!('minutes') }.should raise_error(ArgumentError)
    end
  end

  describe "changing units with in()" do
    it "should handle basic conversions" do
      w = U(1.53, 'kg')
      w.in('grams').should == 1530
      w.in('lbs').to_f.should be_near(3.37)
      w.in('lbs').in('ounces').to_f.should be_near(53.97)
      w.in('pounds').in('grams').in('kg').to_f.should be_near(1.53)
    end

    it "should not allow changing to an unknown unit" do
      w = U(1, 'kg')
      proc { w.in('blorg') }.should raise_error(ArgumentError)
      proc { w.in_blorg }.should raise_error(ArgumentError)
    end

    it "should not allow changing to an incompatible unit" do
      w = U(1, 'kg')
      proc { w.in('minutes') }.should raise_error(ArgumentError)
      proc { w.in_hours }.should raise_error(ArgumentError)
    end
  end
end
