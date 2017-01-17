require 'clearwater/component'
require 'clearwater/black_box_node'

module Clearwater
  class StickyComponent
    include Clearwater::Component

    attr_accessor :props, :renderer
    attr_reader :children

    def self.render props=nil, children=nil
      unless `props === nil || props.$$is_hash`
        children = props
        props = nil
      end

      Wrapper2.new(self, props, children)
    end

    def initialize(props=nil, children=nil)
      @props = self.class.make_props props
      @children = children
    end

    def should_update? next_props
      true
    end

    def component klass, props=nil, children=nil
      klass.render props, children
    end

    def will_receive_props props
    end

    def will_update props
    end

    def did_update old_props
    end

    def will_mount
    end

    def did_mount
    end

    def will_unmount
    end

    def call &block
      if renderer
        renderer.update_dom(&block)
      else
        Clearwater::Application.render(&block)
      end
    end

    def self.make_props props
      if `props.$$is_hash`
        Props.new(props)
      elsif props.nil?
        Props.new
      else
        props
      end
    end

    class Wrapper
      attr_reader :component

      def initialize klass, props=nil, children=nil
        @klass = klass
        @props = StickyComponent.make_props props
        @children = children
        @key = @props.key if @props.key
      end

      %x{
        Opal.defn(self, 'type', 'Thunk');
        Opal.defn(self, 'render', function Component$render(previous) {
          var self = this;

          if(previous &&
             previous.vnode &&
             this.klass === previous.klass &&
             previous.component) {
            self.component = previous.component;

            #{component.will_receive_props @props};
            if(#{component.should_update?(@props)}) {
              #{component.will_update @props};

              var old_props = #{component}.props;
              #{component}.props = #@props;

              #{Bowser.window.animation_frame { component.did_update `old_props` }};

              return #{component.render};
            }

            return previous.vnode;
          } else {
            self.component = #{@klass.new(@props, @children)};
            #{component.will_receive_props @props};

            #{component.will_mount};
            #{Bowser.window.animation_frame { component.did_mount }};
            return #{component.render};
          }
        });
      }
    end

    class Wrapper2
      include Clearwater::BlackBoxNode

      attr_reader :component, :props, :vdom

      def initialize klass, props=nil, children=nil
        @klass = klass
        @props = StickyComponent.make_props props
        @children = children
        @key = @props.key if @props.key
      end

      # Called once before mount, never called again for this component.
      def node
        @component = @klass.new(@props, @children, &@block)
        @node = sanitize_component
      end

      def mount element
        @vdom = Clearwater::VirtualDOM::Document.new(element)

        # Prime the vdom so it doesn't try to render from scratch.
        `#@vdom.node = #{@node}`
        `#@vdom.tree = #{element.to_n}`
        `#@vdom.rendered = true`

        component.will_mount element
        Bowser.window.animation_frame { component.did_mount element }
        component.renderer = self
      end

      def update previous, element
        @component = previous.component
        @vdom = previous.vdom
        component.will_receive_props props

        return unless component.should_update? props

        old_props = previous.props
        component.props = props

        if !component.props.async_render
          component.will_update props
          update_dom
        end

        Bowser.window.animation_frame do
          if component.props.async_render
            component.will_update props
            update_dom
          end

          component.did_update old_props
        end
        component.renderer = self
      end

      def unmount previous
        component.will_unmount
      end

      def update_dom(&block)
        @vdom.render sanitize_component
        block.call if block_given?
      end

      def sanitize_component
        Clearwater::Component.sanitize_content(component)
      end
    end

    class Props
      def initialize props={}
        @props = props
      end

      def merge other
        @props.merge(other)
      end

      def method_missing message, *args
        # We only support fetching props, and extra args mean a method call.
        if args.empty?
          @props[message]
        else
          super
        end
      end

      def to_s
        @props.to_s
      end
    end
  end
end
