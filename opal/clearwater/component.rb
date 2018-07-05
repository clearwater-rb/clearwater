require 'clearwater/virtual_dom'
require 'clearwater/component/html_tags'
require 'clearwater/cached_render'

module Clearwater
  module Component
    attr_accessor :router, :outlet

    def params
      router.params
    end

    def self.sanitize_attributes attributes
      return attributes unless `!!attributes.$$is_hash`

      attributes.each do |key, value|
        if `key.slice(0, 2)` == 'on'
          attributes[key] = proc do |event|
            value.call(Bowser::Event.new(event))
          end
        end
      end

      # Allow specifying `class` instead of `class_name`.
      # Note: `class_name` is still allowed
      if attributes.key?(:class)
        if attributes.key?(:class_name)
          warn "You have both `class` and `class_name` attributes for this " +
            "element. `class` takes precedence: #{attributes}"
        end

        attributes[:class_name] = attributes.delete :class
      end

      attributes
    end

    # Runtime constant lookup isn't free, so if we cache a reference to it we
    # don't have to do it every time we need to sanitize a node's content.
    # This does need to happen at the JS level, though. If we use a Ruby
    # variable, we won't have access to it in the method.
    def self.sanitize_content content
      %x{
        // Is this a Ruby object?
        if(content && content.$$class) {
          if(!content.$$is_array) {
            var render = content.$render;

            if(content.$$cached_render) {
              return #{CachedRender::Wrapper.new(content)};
            } else if(render && !render.$$stub) {
              return #{sanitize_content(content.render)};
            } else {
              return content;
            }
          } else {
            return #{content.map { |c| sanitize_content(c) }};
          }

        // If it's not a Ruby object, it's probably a virtual-dom node.
        } else {
          return content;
        }
      }
    end

    # Default render method for stubbing
    def render
    end

    module_function

    HTML_TAGS.each do |tag_name|
      define_method(tag_name) do |attributes, content|
        %x{
          if(!(attributes === nil || attributes.$$is_hash)) {
            content = attributes;
            attributes = nil;
          }
        }

        tag(tag_name, attributes, content)
      end
    end

    `var vdom = #{VirtualDOM}`
    `var component = self`
    def tag tag_name, attributes=nil, content=nil
      `vdom`.node(
        tag_name,
        `component`.sanitize_attributes(attributes),
        `component`.sanitize_content(content)
      )
    end

    def call &block
      Clearwater::Application::AppRegistry.render_all(&block)
    end
  end
end
