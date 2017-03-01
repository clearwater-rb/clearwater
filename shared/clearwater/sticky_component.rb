require 'clearwater/component'

module Clearwater
  class StickyComponent
    include Clearwater::Component
    include Clearwater::CachedRender

    class << self
      def render(*args)
        Wrapper.new(self, args) { new(*args) }
      end
    end

    def initialize(*args)
      update(*args)
    end

    def should_render? _
      unless @@warned
        warn "You used #{self.class}.new when you might've wanted #{self.class}.render"
        @@warned = true
      end

      true
    end

    def should_update?(*args)
      true
    end

    def update(*args)
    end

    class Wrapper
      attr_reader :component

      def initialize(klass, args, &block)
        @klass = klass
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

  module Component
    def sticky(klass, *args, &block)
      Sticky.new(klass, args, block)
    end

    class Sticky
      attr_reader :component

      def initialize klass, args, block=nil
        @klass = klass
        @args = args
        @block = block
      end

      %x{
        Opal.defn(self, 'type', 'Thunk');
        Opal.defn(self, 'render', function Sticky$render(previous) {
          var self = this;

          if(previous &&
             previous.vnode &&
             this.klass === previous.klass &&
             previous.component) {
            self.component = previous.component;

            if(#{!component.respond_to?(:should_update?) || component.should_update?(*@args)}) {
              if(#{component.respond_to?(:update)}) {
                #{component.update(*@args)};
              }
              return #{component.render};
            }

            return previous.vnode;
          } else {
            self.component = #{@klass.new(*@args, &@block)};
            return #{component.render};
          }

          #{puts component};
        });
      }
    end
  end
end
