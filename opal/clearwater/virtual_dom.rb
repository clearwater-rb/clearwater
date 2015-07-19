require 'browser'
require 'clearwater/virtual_dom/js/virtual_dom.js'

module StringUtils
  def self.camelize string
    string.gsub(/_(\w)/) { |match| match.gsub(/_/, '').upcase }
  end
end

module HashUtils
  def self.camelize_keys(hash)
    return nil if hash.nil?

    camelized = {}
    hash.each do |k, v|
      key = StringUtils.camelize(k)
      value = if v.class == Hash
                camelize_keys(v)
              else
                v
              end

      camelized[key] = value
    end

    camelized
  end
end

module VirtualDOM
  def self.node(tag_name, attributes, content)
    content = Array(content).map { |node|
      case node
      when Node
        node.node
      else
        node
      end
    }
    attributes = HashUtils.camelize_keys(attributes).to_n
    Node.new(`virtualDom.h(tag_name, attributes, content)`)
  end

  def self.create_element node
    `virtualDom.create(node)`
  end

  class Document
    def initialize(root=$document.create_element('div'))
      @root = root
    end

    def render node
      if rendered?
        diff = @node.diff(node)
        @tree.patch diff
        @node = node
      else
        @node = node
        @tree = node.to_element
        @root.inner_dom = @tree.to_n
        @rendered = true
      end
    end

    def rendered?
      @rendered
    end
  end

  class Node
    attr_reader :node

    def initialize(node)
      @node = node
    end

    def method_missing *args, &block
      node.send *args, &block
    end

    def to_element
      Element.new(VirtualDOM.create_element(node))
    end

    def diff other
      `virtualDom.diff(self.node, other.node)`
    end

    def patch diff
      `virtualDom.patch(#{to_element.to_n}, diff)`
    end
  end

  class Element
    def initialize(element)
      @element = element
    end

    def patch(diff)
      `virtualDom.patch(#{to_n}, diff)`
    end

    def to_n
      @element
    end
  end
end
