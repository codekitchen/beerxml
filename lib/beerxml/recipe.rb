class Beerxml::Recipe < Beerxml::Model
  include DataMapper::Resource

  property :name, String, :required => true

  has n, :hops

  # these are not used in the xml
  property :id, Serial
end
