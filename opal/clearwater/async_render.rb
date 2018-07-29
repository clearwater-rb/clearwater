require 'clearwater/virtual_dom'
require 'clearwater/black_box_node'

module Clearwater
  class AsyncRender
    include Clearwater::BlackBoxNode

    attr_reader :vnode

    def initialize &content
      @content = content
    end

    # Specify a temporary node to use. It will be replaced with the content
    # passed in.
    def node
      Component.span
    end

    def mount element
      delayed_update nil, element
    end

    def update previous, element
      delayed_update previous.vnode, element
    end

    def delayed_update from, element
      Bowser.window.animation_frame do
        @vnode = Component.sanitize_content(@content.call)
        diff = VirtualDOM.diff from, @vnode
        VirtualDOM.patch element.to_n, diff
      end
    end
  end

  module Component
    def async_render &block
      AsyncRender.new &block
    end
  end
end
