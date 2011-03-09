require "#{File.dirname(__FILE__)}/spec_helper"

include Beerxml

describe "Centennial Blonde" do
  before(:each) do
    # http://www.homebrewtalk.com/f66/centennial-blonde-simple-4-all-grain-5-10-gall-42841/
    @recipe = Recipe.new(:name => 'Centennial Blonde',
                         :type => 'All Grain',
                         :brewer => 'BierMuncher',
                         :batch_size => U(5.5, 'gallons'),
                         :boil_size => U(6.75, 'gallons'),
                         :boil_time => U(60, 'minutes'),
                         :efficiency => 70.0)
    @recipe.hops << Hop.new(:name => 'Centennial',
                            :alpha => 9.5,
                            :amount => U('0.25 oz'),
                            :use => 'Boil',
                            :time => 55)
    @recipe.hops << Hop.new(:name => 'Centennial',
                            :alpha => 9.5,
                            :amount => U('0.25 oz'),
                            :use => 'Boil',
                            :time => 35)
    @recipe.hops << Hop.new(:name => 'Cascade',
                            :alpha => 7.8,
                            :amount => U('0.25 oz'),
                            :use => 'Boil',
                            :time => 20)
    @recipe.hops << Hop.new(:name => 'Cascade',
                            :alpha => 7.8,
                            :amount => U('0.25 oz'),
                            :use => 'Boil',
                            :time => 5)
    @recipe.fermentables << Fermentable.new(:name => 'Pale Malt (2 Row)',
                                            :type => 'Grain',
                                            :amount => U(7, 'lb'),
                                            :ppg => 37,
                                            :color => 2)
    @recipe.fermentables << Fermentable.new(:name => 'Cara-Pils',
                                            :type => 'Grain',
                                            :amount => U(0.75, 'lb'),
                                            :ppg => 33,
                                            :color => 2)
    @recipe.fermentables << Fermentable.new(:name => 'Crystal 10L',
                                            :type => 'Grain',
                                            :amount => U(0.5, 'lb'),
                                            :ppg => 35,
                                            :color => 10)
    @recipe.fermentables << Fermentable.new(:name => 'Vienna',
                                            :type => 'Grain',
                                            :amount => U(0.5, 'lb'),
                                            :ppg => 35,
                                            :color => 4)
    @recipe.yeasts << Yeast.new(:name => 'Nottingham',
                                :type => 'Ale',
                                :form => 'Dry',
                                :amount => U(0.2, 'liter'),
                                :attenuation => 75)
    @recipe.should be_valid
  end

  it "should calculate basic stats" do
    @recipe.ibus.round.should == 20
    @recipe.calculate_og.should == 1.041
    @recipe.calculate_fg.should == 1.010
    @recipe.color == 3.9
  end
end
