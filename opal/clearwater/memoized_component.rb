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

    def initialize *args
      @__args = args
    end

    def update *args
      @__args = args
    end

    def destroy
    end

    def should_update? *args
      args != @__args
    end

    class Placeholder
      # include Clearwater::CachedRender
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

      # def should_render? previous
      #   return true if klass != previous.klass

      #   @component = previous.component

      #   should_update = component.should_update?(*@args)
      #   component.update(*@args, &@block) if should_update

      #   should_update
      # end

      # def render
      #   component.render
      # end

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
