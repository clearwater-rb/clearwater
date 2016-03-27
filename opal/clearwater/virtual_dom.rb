require 'clearwater/virtual_dom/js/virtual_dom.js'

module VirtualDOM
  %x{ var camelized_native; }

  def self.node(tag_name, attributes, content)
    %x{
      return virtualDom.h(
        tag_name,
        camelized_native.$call(attributes),
        #{sanitize_content(content)}
      )
    }
  end

  def self.svg(tag_name, attributes=nil, content=nil)
    %x{
      return virtualDom.svg(
        tag_name,
        #{HashUtils.camelized_native(attributes)},
        #{sanitize_content(content)}
      );
    }
  end

  def self.create_element(node)
    `virtualDom.create(node)`
  end

  def self.diff first, second
    `virtualDom.diff(first, second)`
  end

  def self.patch node, diff
    `virtualDom.patch(node, diff)`
  end

  def self.sanitize_content content
    %x{
      if(content === Opal.nil || content === undefined) return null;
      if(content.$$is_array)
        return #{content.map! { |c| sanitize_content c }};
      return content;
    }
  end

  class Document
    def initialize(root=Bowser.document.create_element('div'))
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
    %x{
      function camelize_handler(ignored, character_match) {
        return character_match.toUpperCase();
      }
    }

    def self.camelize string
      `string.replace(/_(\w)/g, camelize_handler)`
    end
  end

  module HashUtils
    %x{ var camelize = #{StringUtils.method(:camelize)}.method; }

    def self.camelized_native hash
      %x{
        if(!(hash && hash.$$is_hash)) return #{hash.to_n};

        var v, keys = #{hash.keys}, key, js_obj = {};
        for(var index = 0; index < keys.length; index++) {
          key = keys[index];
          v = #{hash[`key`]};
          js_obj[camelize(key)] = v.$$is_hash ? #{camelized_native(`v`)} : v
        }
        return js_obj;
      }
    end
  end
  %x{ camelized_native = #{HashUtils.method(:camelized_native)}; }
end
