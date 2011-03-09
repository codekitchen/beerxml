require 'dm-core'
require 'dm-validations'
require 'nokogiri'

module Beerxml
  # This'll have to go eventually, but for now it's nice
  DataMapper.setup(:default, "abstract::")

  def self.parse(string_or_io)
    Beerxml::Model.from_xml(Nokogiri::XML(string_or_io).root)
  end

  def self.round(float, to = 0)
    exp = 10 ** to
    (float * exp).round.to_f / exp
  end
end

require 'beerxml/model'
