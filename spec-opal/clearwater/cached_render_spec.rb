require 'clearwater/component'
require 'clearwater/cached_render'

module Clearwater
  describe CachedRender do
    let(:component_class) {
      Class.new do
        include Clearwater::Component
        include Clearwater::CachedRender

        def initialize value
          @value = value
        end

        def render
          @value.to_s
        end
      end
    }
    let(:value) { double }
    let(:component) { component_class.new(value) }

    it 'memoizes the return value of render' do
      component = component()

      expect(value).to receive(:to_s)
      %x{ component.render(component) }

      component.instance_exec { @vnode = VirtualDOM.node('div', 'howdy') }
      expect(value).not_to receive(:to_s)

      2.times { `component.render(component)` }
    end

    it 'uses should_render? to determine whether to call render again' do
      component = component()
      def component.should_render?
        true
      end

      expect(value).to receive(:to_s).twice

      2.times { `component.render(component)` }
    end

    it 'allows nested CachedRender renders' do
      foo = Class.new do
        include Clearwater::Component
        include Clearwater::CachedRender

        def render
          'hi'
        end
      end

      bar = Class.new do
        include Clearwater::Component
        include Clearwater::CachedRender

        define_method :render do
          foo.new
        end
      end.new

      expect(`bar.render()`).to eq 'hi'
    end
  end
end
