require 'bowser/element'
require 'clearwater/virtual_dom'
require 'clearwater/component'

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

    def key
    end

    class Renderable
      attr_reader :delegate

      def initialize delegate
        @delegate = delegate
        if delegate.key
          @key = delegate.key
        end
      end

      def wrap node
        Bowser::Element.new(node) if node
      end

      def create_element
        sanitized = Clearwater::Component.sanitize_content(@delegate.node)
        vnode = VirtualDOM.create_element(sanitized)
        wrap(vnode)
      end

      %x{
        // Use the virtual-dom Widget type
        (self.$$proto || self.prototype).type = 'Widget';

        // virtual-dom Widget init hook. Must return a real DOM node.
        // We call the Ruby-land #mount method so we can define hooks for this
        // in Ruby instead of requiring users to drop down to JS.
        (self.$$proto || self.prototype).init = function() {
          var self = this;
          var node = #{create_element};
          #{@delegate.mount(`node`)};
          return node['native'];
        };

        // virtual-dom update hook
        //   previous: the instance of this object used in the previous render
        //   node: a Bowser-wrapped version of the DOM node
        (self.$$proto || self.prototype).update = function(previous, node) {
          var self = this;

          if(self.delegate.$$class === previous.delegate.$$class) {
            var result = #{@delegate.update(`previous.delegate`, wrap(`node`))};

            if(result && result.$$class && #{Bowser::Element === `result`}) {
              return #{`result`.to_n};
            }
          } else {
            previous.destroy(#{wrap(`node`)});
            var new_node = #{create_element};
            #{@delegate.mount(`new_node`)};
            return new_node['native'];
          }
        };

        // virtual-dom destroy hook
        //   node: Bowser-wrapped version of the DOM node
        (self.$$proto || self.prototype).destroy = function(node) {
          var self = this;
          #{@delegate.unmount(wrap(`node`))};
        };
      }
    end
  end
end
