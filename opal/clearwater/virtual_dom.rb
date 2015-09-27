require 'browser'
require 'clearwater/virtual_dom/js/virtual_dom.js'

module VirtualDOM
  def self.node(tag_name, attributes, content)
    content = sanitize_content(content)
    attributes = HashUtils.camelize_keys(attributes).to_n
    `virtualDom.h(tag_name, attributes, content)`
  end

  def self.diff first, second
    `virtualDom.diff(first, second)`
  end

  def self.patch node, diff
    `virtualDom.patch(node, diff)`
  end

  def self.sanitize_content content
    %x{
      if(content === Opal.nil) return Opal.nil;
      if(content.$$class === Opal.Array)
        return #{content.map!{ |c| sanitize_content c }};
      return content;
    }
  end

  class Document
    def initialize(root=$document.create_element('div'))
      @root = root
    end

    def render node
      if rendered?
        diff = VirtualDOM.diff @node, node
        VirtualDOM.patch @tree, diff
        @node = node
      else
        @node = node
        @tree = create_element(node)
        @root.inner_dom = @tree
        @rendered = true
      end
    end

    def create_element node
      `virtualDom.create(node)`
    end

    def rendered?
      @rendered
    end
  end

  module StringUtils
    def self.camelize string
      %x{
        return string.replace(/_(\w)/g, function(full_match, character_match) {
          return character_match.toUpperCase();
        })
      }
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
end
