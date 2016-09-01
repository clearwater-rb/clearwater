require 'clearwater/router'
require 'ostruct'

module Clearwater
  RSpec.describe Router do
    let(:component_class) {
      Class.new do
        include Clearwater::Component
      end
    }
    let(:routed_component) { component_class.new }
    let!(:router) {
      component = routed_component
      Router.new do
        route 'articles' => component do
          route ':article_id' => component
        end
      end
    }

    it 'sets the router for a routed component' do
      expect(routed_component.router).to be router
    end

    it 'gets the params for a given path' do
      expect(router.params('/articles/foo')).to eq article_id: 'foo'
    end

    it 'gets the components for a given path' do
      expect(router.targets_for_path('/articles/1')).to eq [
        routed_component, routed_component
      ]

      expect(router.targets_for_path('/articles')).to eq [routed_component]
    end

    it 'gets the current path' do
      location = OpenStruct.new(path: '/foo')
      router = Router.new(location: location)

      expect(router.current_path).to eq '/foo'

      location.path = '/bar'

      expect(router.current_path).to eq '/bar'
    end

    it 'gets the params from the path' do
      expect(router.params('/articles/123')).to eq({ article_id: '123' })
    end

    it 'gets params with a namespace' do
      component = routed_component
      router = Router.new do
        namespace 'clearwater'

        route 'articles' => component do
          route ':article_id' => component
        end
      end

      expect(router.params('/clearwater/articles/123')).to eq({ article_id: '123' })
    end

    it 'calls route transitions on routing targets' do
      router = Router.new
      component_class = Class.new do
        include Clearwater::Component

        attr_reader :transition_to, :transition_away

        def initialize
          @transition_to = 0
          @transition_away = 0
        end

        def on_route_to
          @transition_to += 1
        end

        def on_route_from
          @transition_away += 1
        end
      end

      targets = [
        component_class.new,
        component_class.new,
        component_class.new,
      ]
      router.set_outlets [targets[0], targets[1]]
      router.set_outlets [targets[0], targets[2]]
      router.set_outlets [targets[0], targets[1]]
      router.set_outlets [targets[0]]

      expect(targets[0].transition_to).to eq 1
      expect(targets[0].transition_away).to eq 0
      expect(targets[1].transition_to).to eq 2
      expect(targets[1].transition_away).to eq 2
      expect(targets[2].transition_to).to eq 1
      expect(targets[2].transition_away).to eq 1
    end
  end
end
