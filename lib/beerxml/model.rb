class Beerxml::Model
  include DataMapper::Resource
  require 'beerxml/properties'
  include Beerxml::Properties

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
    @plurals[klass.beerxml_plural_name] = klass
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
    # load any relationships with other beerxml models
    relationships.each do |name, rel|
      # don't ever serialize the parent recipe
      next if rel.name == :recipe
      if rel.max == 1
        (node>rel.child_model.beerxml_name).each do |child_node|
          self.send("#{rel.name}=", rel.child_model.new.from_xml(child_node))
        end
      else
        # look for the plural element in the children of this node
        # e.g., for Hop, see if there's any HOPS element.
        (node>rel.child_model.beerxml_plural_name).each do |child_wrapper_node|
          collection = Beerxml::Model.collection_from_xml(child_wrapper_node)
          self.send(rel.name).concat(collection)
        end
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

  def self.to_beerxml_collection(collection, parent = Nokogiri::XML::Document.new)
    raise(ArgumentError, "All must be of the same type") if collection.any? { |n| !n.is_a?(self) }
    node = Nokogiri::XML::Node.new(self.beerxml_plural_name, parent)
    collection.each do |n|
      n.to_beerxml(node)
    end
    parent.add_child(node)
    parent
  end

  def to_beerxml(parent = Nokogiri::XML::Document.new)
    # TODO: do we raise an error if not valid?
    node = Nokogiri::XML::Node.new(self.class.beerxml_name, parent)
    attributes.each do |attr, val|
      next if attr.to_s.match(/id\z/) || val.nil?
      x = Nokogiri::XML::Node.new(self.class.xml_attr_name(attr), parent)
      x.content = self.class.properties[attr].dump(val)
      node.add_child(x)
    end
    relationships.each do |name, rel|
      # don't ever serialize the parent recipe
      next if rel.name == :recipe
      if rel.max == 1
        obj = self.send(rel.name)
        next if obj.nil?
        obj.to_beerxml(node)
      else
        objs = self.send(rel.name)
        next if objs.empty?
        sub_node = Nokogiri::XML::Node.new(rel.child_model.beerxml_plural_name, node)
        node.add_child(sub_node)
        objs.each { |o| o.to_beerxml(sub_node) }
      end
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

%w(hop recipe fermentable yeast style).
  each { |f| require "beerxml/#{f}" }
