require 'clearwater/component'
require 'clearwater/black_box_node'

module Clearwater
  class MemoizedComponent
    include Clearwater::Component

    def self.memoize *args, &block
      Placeholder.new(self, args, block)
    end

    def self.[] key
      memoize[key]
    end

    def should_update?
      true
    end

    def update
    end

    def destroy
    end

    def render
      div
    end

    class Placeholder
      include Clearwater::BlackBoxNode

      attr_reader :klass, :key, :vdom

      def initialize klass, args, block
        @klass = klass
        @args = args
        @block = block
      end

      def memoize *args, &block
        initialize @klass, args, block
        self
      end

      def [] key
        @key = key.to_s
        self
      end

      def component
        @component ||= @klass.new(*@args, &@block)
      end

      def node
        @node ||= Clearwater::Component.sanitize_content(component)
      end

      def mount element
        @vdom = VirtualDOM::Document.pre_rendered(element, node)
      end

      def update previous, element
        # if we're looking at different classes, we need to start from scratch
        if klass != previous.klass
          previous.unmount element

          new_element = render.create_element
          mount new_element
          new_element
        else
          @vdom = previous.vdom
          @component = previous.component

          if component.should_update?(*@args, &@block)
            component.update(*@args, &@block)
            @vdom.render Clearwater::Component.sanitize_content(component.render)
          end
        end
      end

      def unmount
        component.destroy
        @vdom.render Clearwater::Component.div # Clean up vdom by removing everything
      end
    end
  end
end
