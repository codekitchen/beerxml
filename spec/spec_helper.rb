require 'beerxml'

require 'rspec'

Beerxml::Unit.apply_to_numeric!

RSpec.configure do |c|
  def filename(example)
    "examples/beerxml.com/#{example}.xml"
  end
  def read_file(example)
    File.read(filename(example))
  end
  def read_xml(example)
    Nokogiri::XML(read_file(example))
  end
end
