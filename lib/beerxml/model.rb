class Beerxml::Model
  include DataMapper::Resource

  ##########################

  @models = {}
  @plurals = {}

  def self.beerxml_name
    name.split('::').last.upcase
  end

  def self.beerxml_plural_name
    "#{beerxml_name}S"
  end

  def self.inherited(klass)
    super
    @models[klass.beerxml_name] = klass
    @plurals["#{klass.beerxml_name}S"] = klass
  end

  ##########################

  # Takes a Nokogiri node, figures out what sort of class it is, and parses it.
  # Raises if it's not a Beerxml::Model class (or collection).
  def self.from_xml(node)
    if model = @models[node.name]
      model.new.from_xml(node)
    elsif model = @plurals[node.name]
      collection_from_xml(node)
    else
      raise "Unknown BeerXML node type: #{node.name}"
    end
  end

  # Parse a Nokogiri node, reading in the properties defined on this model.
  # Assumes the node is of the correct type.
  def from_xml(node)
    properties.each do |property|
      read_xml_field(node, property.name.to_s)
    end
    # load any has-many relationships with other beerxml models
    relationships.each do |name, rel|
      child_model = rel.child_model
      next unless child_model.ancestors.include?(Beerxml::Model)

      # look for the plural element in the children of this node
      # e.g., for Hop, see if there's any HOPS element.
      (node>child_model.beerxml_plural_name).each do |child_wrapper_node|
        collection = Beerxml::Model.collection_from_xml(child_wrapper_node)
        self.send(rel.name).concat(collection)
      end
    end
    self
  end

  # takes a collection root xml node, like <HOPS>, and returns an array of the
  # child model objects inside the node.
  def self.collection_from_xml(collection_node)
    model = @plurals[collection_node.name]
    raise("Unknown model: #{collection_node.name}") unless model
    (collection_node>model.beerxml_name).map do |child_node|
      model.new.from_xml(child_node)
    end
  end

  def read_xml_field(node, attr_name, node_name = attr_name.upcase)
    child = (node>node_name).first
    return unless child
    child = child.text
    child = yield(child) if block_given?
    self.send("#{attr_name}=", child)
  end

  ##########################

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

%w(hop recipe fermentable).
  each { |f| require "beerxml/#{f}" }
