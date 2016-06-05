require 'clearwater/virtual_dom/js/virtual_dom.js'

module VirtualDOM
  def self.node(tag_name, attributes=nil, content=nil)
    %x{
      return virtualDom.h(
        tag_name,
        #{HashUtils.camelized_native(attributes)},
        #{sanitize_content(content)}
      );
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
        return #{content.map!{ |c| sanitize_content c }};
      return content;
    }
  end

  class Document
    def initialize(root=Bowser.document.create_element('div'))
      @root = root
    end

    def render node
      if !rendered?
        @rendered = true

        # If we rendered the app on the server, we hydrate the rendered app
        # rather than replacing it. This provides a faster and more memory-
        # efficient first vdom render.
        if `#@root.native.children.length > 0`
          @tree = `#@root.native.children[0]`
          @node = `virtualDom.virtualize(#@tree)`
        else # Not server-rendered, generate from scratch.
          @node = node
          @tree = VirtualDOM.create_element(node)
          @root.inner_dom = @tree
          return
        end
      end

      diff = VirtualDOM.diff @node, node
      VirtualDOM.patch @tree, diff
      @node = node
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
      return hash.to_n unless `!!hash.$$is_hash`

      %x{
        var v, keys = #{hash.keys}, key, js_obj = {};
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
