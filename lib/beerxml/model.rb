class Beerxml::Model
  include DataMapper::Resource

  def self.beerxml_name
    name.split('::').last.upcase
  end

  def from_xml(node)
    properties.each do |property|
      read_xml_field(node, property.name.to_s)
    end
    # load any has-many relationships with other beerxml models
    relationships.each do |name, rel|
      child_model = rel.child_model
      next unless child_model.ancestors.include?(Beerxml::Model)

      model_name = child_model.beerxml_name
      child_wrapper_node = (node>model_name.pluralize.upcase).first
      next unless child_wrapper_node

      (child_wrapper_node>model_name).each do |child_node|
        self.send(rel.name) << child_model.new.from_xml(child_node)
      end
    end
    self
  end

  def read_xml_field(node, attr_name, node_name = attr_name.upcase)
    child = (node>node_name).first
    return unless child
    child = child.text
    child = yield(child) if block_given?
    self.send("#{attr_name}=", child)
  end

  def to_beerxml(parent = Nokogiri::XML::Document.new)
    # TODO: do we raise an error if not valid?
    node = Nokogiri::XML::Node.new(self.class.beerxml_name, parent)
    attributes.each do |attr, val|
      next if attr.to_s.match(/id\z/) || val.nil?
      x = Nokogiri::XML::Node.new(self.class.xml_attr_name(attr), parent)
      x.content = val # TODO: data types
      node.add_child(x)
    end
    parent.add_child(node)
    parent
  end

  def to_xml
    to_beerxml.to_s
  end

  def self.xml_attr_name(name)
    name.to_s.upcase
  end
end

require 'beerxml/hop'
require 'beerxml/recipe'
