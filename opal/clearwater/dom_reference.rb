module Clearwater
  class DOMReference
    def mount node, previous
      @node = node
    end

    def unmount node, previous
    end

    def method_missing *args, &block
      @node.public_send *args, &block
    end

    def wrap node
      Bowser::Element.new(node)
    end

    %x{
      Opal.defn(self, 'hook', function(node, name, previous) {
        var self = this;
        #{mount(wrap(`node`), `previous`)};
      });

      Opal.defn(self, 'unhook', function(node, name, previous) {
        var self = this;
        #{unmount(wrap(`node`), `previous`)};
      });
    }
  end
end
