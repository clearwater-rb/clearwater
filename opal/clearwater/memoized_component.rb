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
        @vdom = VirtualDOM::Document.new(element)

        # TODO: add a public interface to generate a pre-initialized VDOM::Doc
        `#@vdom.tree = #{element.to_n}`
        `#@vdom.node = #{node}`
        `#@vdom.rendered = true`
      end

      def update previous
        @vdom = previous.vdom
        @component = previous.component

        if component.should_update?(*@args, &@block)
          component.update(*@args, &@block)
          @vdom.render component.render
        end
      end

      def unmount
        component.destroy
      end
    end
  end
end
