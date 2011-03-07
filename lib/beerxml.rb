require 'dm-core'
require 'dm-types'
require 'dm-validations'
require 'nokogiri'

module Beerxml
  # This'll have to go eventually, but for now it's nice
  DataMapper.setup(:default, "abstract::")
end

require 'beerxml/model'
