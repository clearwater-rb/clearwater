require 'browser'
require 'clearwater/virtual_dom/js/virtual_dom.js'

module StringUtils
  def self.camelize string
    string.gsub(/_(\w)/) { |match| match.gsub(/_/, '').upcase }
  end
end

module HashUtils
  def self.camelize_keys(hash)
    return hash unless hash.is_a? Hash

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
    content = sanitize_content(content)
    attributes = HashUtils.camelize_keys(attributes).to_n
    Node.new(`virtualDom.h(tag_name, attributes, content)`)
  end

  def self.sanitize_content content
    %x{
      if(content === Opal.nil) return Opal.nil;
      if(content.$$class === Opal.Array)
        return #{content.map!{ |c| sanitize_content c }};
      if(content.$$class === Opal.VirtualDOM.Node) return content.node;
      return content;
    }
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
        @tree = Element.new(create_element(node))
        @root.inner_dom = @tree.to_n
        @rendered = true
      end
    end

    def create_element node
      `virtualDom.create(node.node)`
    end

    def rendered?
      @rendered
    end
  end

  class Node
    def initialize(node)
      @node = node
    end

    def diff other
      `virtualDom.diff(self.node, other.node)`
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
