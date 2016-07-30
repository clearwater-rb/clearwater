require 'clearwater/component'
require 'clearwater/cached_render'
require 'clearwater/cached_render/wrapper'

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
    let(:value) { double(to_s: 'value') }
    let(:component) { component_class.new(value) }
    let(:wrapper) { CachedRender::Wrapper.new(component) }

    it 'memoizes the return value of render' do
      wrapper = self.wrapper

      expect(value).to receive(:to_s)
      %x{ wrapper.render(wrapper) }

      wrapper.instance_exec { @vnode = VirtualDOM.node('div', 'howdy') }

      expect(value).not_to receive(:to_s)
      2.times { `wrapper.render(wrapper)` }
    end

    it 'uses should_render? to determine whether to call render again' do
      wrapper = self.wrapper

      def component.should_render?
        true
      end

      expect(value).to receive(:to_s).twice

      2.times { `wrapper.render(wrapper)` }
    end

    it "uses the component's key method as its own vdom key" do
      def component.key
        '123'
      end

      wrapper = CachedRender::Wrapper.new(component)
      expect(`wrapper.key`).to eq '123'
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

      wrapper = CachedRender::Wrapper.new(bar)

      expect(`wrapper.render()`).to eq 'hi'
    end
  end
end
