require 'dm-core'
require 'dm-types'
require 'dm-validations'
require 'nokogiri'

module Beerxml
  # This'll have to go eventually, but for now it's nice
  DataMapper.setup(:default, "abstract::")

  def self.parse(string_or_io)
    Beerxml::Model.from_xml(Nokogiri::XML(string_or_io).root)
  end
end

require 'beerxml/model'
