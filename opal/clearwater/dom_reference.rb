module Clearwater
  class DOMReference
    attr_reader :node

    def mount node, previous
      @node = node
    end

    def unmount node, previous
      @node = nil
    end

    def mounted?
      !!@node
    end

    def method_missing *args, &block
      if @node.nil?
        raise TypeError, "#{self} has not been mounted, received #{args}"
      end

      @node.public_send *args, &block
    end

    def wrap node
      Bowser::Element.new(node)
    end

    # This can be treated as a native JS object. This method is required for
    # some versions of Opal that cast Ruby objects as `nil` if they don't
    # respond to to_n.
    def to_n
      self
    end

    %x{
      Opal.defn(self, 'hook', function(node, name, previous) {
        var self = this;
        #{mount(wrap(`node`), `previous == null ? nil : previous`)};
      });

      Opal.defn(self, 'unhook', function(node, name, previous) {
        var self = this;
        #{unmount(wrap(`node`),  `previous == null ? nil : previous`)};
      });
    }
  end
end
