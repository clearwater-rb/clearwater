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
      expect(value).to receive(:to_s).once

      2.times { component.cached_render }
    end

    it 'uses should_render? to determine whether to call render again' do
      def component.should_render?
        true
      end

      expect(value).to receive(:to_s).twice

      2.times { component.cached_render }
    end
  end
end
