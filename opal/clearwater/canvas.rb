require 'clearwater/dom_reference'
require 'bowser/element/canvas'

module Clearwater
  module Canvas
    def canvas(**properties, &block)
      ref = Canvas.new(block)

      tag(:canvas, ref: ref, **properties)
    end

    class Canvas < Clearwater::DOMReference
      def initialize block
        @block = block || proc {}
      end

      def mount node, previous
        super

        Bowser.window.animation_frame do
          @block.call node.context
        end
      end
    end
  end
end
