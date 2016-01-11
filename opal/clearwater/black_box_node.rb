require 'bowser/element'
require 'clearwater/virtual_dom'

module Clearwater
  module BlackBoxNode
    def node
      VirtualDOM.node :div
    end

    def mount node
    end

    def update previous, node
    end

    def unmount node
    end

    def render
      Renderable.new(self)
    end

    class Renderable
      def initialize delegate
        @delegate = delegate
      end

      def wrap node
        Bowser::Element.new(node)
      end

      def create_element
        wrap(VirtualDOM.create_element(@delegate.node))
      end

      %x{
        // Use the virtual-dom Widget type
        Opal.defn(self, 'type', 'Widget');

        // virtual-dom Widget init hook. Must return a real DOM node.
        // We call the Ruby-land #mount method so we can define hooks for this
        // in Ruby instead of requiring users to drop down to JS.
        Opal.defn(self, 'init', function() {
          var self = this;
          var node = #{create_element};
          #{@delegate.mount(`node`)};
          return node.native;
        });

        // virtual-dom update hook
        //   previous: the instance of this object used in the previous render
        //   node: a Bowser-wrapped version of the DOM node
        Opal.defn(self, 'update', function(previous, node) {
          var self = this;
          #{@delegate.update(`previous.delegate`, wrap(`node`))};
        });

        // virtual-dom destroy hook
        //   node: Bowser-wrapped version of the DOM node
        Opal.defn(self, 'destroy', function(node) {
          var self = this;
          #{@delegate.unmount(wrap(`node`))};
        });
      }
    end
  end
end
