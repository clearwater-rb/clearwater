require 'clearwater/virtual_dom/js/virtual_dom.js'

module Clearwater
  module VirtualDOM
    `var hash_utils;`

    def self.node(tag_name, attributes=nil, content=nil)
      %x{
        return virtualDom.h(
          tag_name,
          #{`hash_utils`.camelized_native(attributes)},
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
        if(content === #{nil} || content == null) return null;
        if(content.$$is_array)
          return #{content.map!{ |c| sanitize_content c }};
        return content.valueOf();
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
      # Speed up camelization like whoa.
      %x{ var camelized_cache = {}; }

      def self.camelize string
        %x{
          if(camelized_cache.hasOwnProperty(string)) {
            return camelized_cache[string];
          } else {
            camelized_cache[string] = string.replace(/_(\w)/g, self.$_camelize_handler);
            return camelized_cache[string];
          }
        }
      end

      def self._camelize_handler _, character_match
        `character_match.toUpperCase()`
      end
    end

    module HashUtils
      `var string_utils = #{StringUtils}`

      def self.camelized_native hash
        return hash.to_n unless `!!hash.$$is_hash`

        %x{
          var v, keys = #{hash.keys}, key, js_obj = {};
          for(var index = 0; index < keys.length; index++) {
            key = keys[index];
            v = #{hash[`key`]};
            js_obj[#{`string_utils`.camelize(`key`)}] = v.$$is_hash
              ? self.$camelized_native(v)
              : (
                (v && v.$$class) // If this is a Ruby object, nativize it
                  ? #{`v`.to_n}
                  : v
                );
          }
          return js_obj;
        }
      end
    end
    `hash_utils = #{HashUtils}`
  end
end
