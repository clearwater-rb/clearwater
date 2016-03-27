require 'clearwater/virtual_dom/js/snabbdom.js'

module VirtualDOM
  def self.node(tag_name, attributes, content)
    %x{
      return snabbdom.h(
        tag_name,
        {
          props: camelized_native.$call(attributes),
        },
        #{sanitize_content(content)}
      )
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

  def self.thunk component
    Thunk.create component
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
    %x{
      var camelize_handler = function(ignored, character_match) {
        return character_match.toUpperCase();
      };
    }

    def self.camelize string
      `string.replace(/_(\w)/g, camelize_handler)`
    end
  end

  module HashUtils
    %x{ var camelize = #{StringUtils.method(:camelize)}; }

    def self.camelized_native hash
      return `{}` if `hash === nil`
      return hash unless `!!hash.$$is_hash`

      %x{
        if(!(hash && hash.$$is_hash)) return #{hash.to_n};

        if(!self.camelize) self.camelize = #{StringUtils.method(:camelize)};

        var v, keys = #{hash.keys}, key, js_obj = {};
        for(var index = 0; index < keys.length; index++) {
          key = keys[index];
          v = #{hash[`key`]};
          js_obj[camelize.$call(key)] = v.$$is_hash ? #{camelized_native(`v`)} : v
        }
        return js_obj;
      }
    end
  end
  %x{ camelized_native = #{HashUtils.method(:camelized_native)}; }

  module Thunk
    module_function

    def create component
      `snabbdom.h(#{"thunk-#{component.class}"}, {
        hook: {
          init: self.$init,
          prepatch: self.$prepatch,
        },
        component: component,
      })`
    end

    def init thunk
      component = `thunk.data.component`
      %x{
        component.$$vnode = component.$render();
        thunk.data.vnode = component.$$vnode;
      }
    end

    def prepatch old, current
      component = `current.data.component`
      previous = `old.data.component`

      %x{
        if(component === previous) {
          current.data.vnode = old.data.vnode;
          return;
        }

        var should_render = #{component.should_render?(previous)};
        if(!should_render) {
          current.data.vnode = old.data.vnode;
        }
      }
    end
  end
end
