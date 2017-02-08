require 'clearwater/component'

module Clearwater
  class StickyComponent
    include Clearwater::Component

    class << self
      alias_method :_new, :new
      def new(*args)
        Wrapper.new(*args) { |*arguments| _new(*arguments) }
      end
    end

    def initialize(*args)
      update(*args)
    end

    def should_update?(*args)
      true
    end

    def update(*args)
    end

    class Wrapper
      attr_reader :component

      def initialize(*args, &block)
        @args = args
        @block = block
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

            if(#{component.should_update?(*@args)}) {
              #{component.update(*@args)};
              return #{component.render};
            }

            return previous.vnode;
          } else {
            self.component = #{@block.call(*@args)};
            return #{component.render};
          }
        });
      }
    end
  end
end
