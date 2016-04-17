require 'clearwater/virtual_dom/js/snabbdom.js'

module VirtualDOM
  def self.node(tag_name, attributes=nil, content=nil)
    %x{
      return snabbdom.h(
        tag_name,
        {
          props: #{HashUtils.camelized_native(attributes)},
        },
        #{sanitize_content(content)}
      );
    }
  end

  def self.svg(tag_name, attributes=nil, content=nil)
    %x{
      return snabbdom.h(
        tag_name,
        #{HashUtils.camelized_native(attributes)},
        #{sanitize_content(content)}
      );
    }
  end

  def self.patch old, new
    `snabbdom.patch(old, #{new})`
  end

  def self.sanitize_content content
    %x{
      if(content === Opal.nil || content === undefined) return null;
      if(content.$$is_array)
        return #{content.map!{ |c| sanitize_content c }};
      return content;
    }
  end

  class Document
    def initialize(root=Bowser.document.create_element('div'))
      @root = root
    end

    def render node
      if rendered?
        VirtualDOM.patch @node, node
        @node = node
      else
        VirtualDOM.patch `#@root.native`, node
        @node = node
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
      `string.replace(/_(\w)/g, self.$_camelize_handler)`
    end

    def self._camelize_handler _, character_match
      `character_match.toUpperCase()`
    end
  end

  module HashUtils
    def self.camelized_native hash
      return `{}` if `hash === nil`
      return hash.to_n unless `!!hash.$$is_hash`

      %x{
        var v, keys = hash.$$keys, key, js_obj = {};
        for(var index = 0; index < keys.length; index++) {
          key = keys[index];
          v = #{hash[`key`]};
          js_obj[#{StringUtils.camelize(`key`)}] = v.$$is_hash ? self.$camelized_native(v) : v
        }
        return js_obj;
      }
    end
  end
end
