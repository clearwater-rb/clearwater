require 'clearwater/router'
require 'clearwater/component'
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

    context "route transitions" do
      let(:component_class) do
        Class.new do
          include Clearwater::Component

          attr_reader :route_to, :route_from

          def initialize
            @route_to = 0
            @route_from = 0
          end

          def on_route_to
            @route_to += 1
          end

          def on_route_from
            @route_from += 1
          end
        end
      end

      let(:parent) { component_class.new }
      let(:child) { component_class.new }
      let(:sibling) { component_class.new }
      let(:dynamic) { component_class.new }
      let(:dynamic_child) { component_class.new }

      let(:router) do
        targets = [parent, child, sibling, dynamic, dynamic_child]
        Router.new do
          route 'parent' => targets[0] do
            route 'child' => targets[1]
            route 'sibling' => targets[2]
            route ':id' => targets[3] do
              route 'dynamic_child' => targets[4]
            end
          end
        end
      end

      it '/parent => /parent/child' do
        router.trigger_routing_callbacks previous_path: '/parent', path: '/parent/child'

        expect(child.route_to).to eq(1)
        expect(parent.route_to).to eq(0)
        expect(parent.route_from).to eq(0)
      end

      it '/parent/child => /parent' do
        router.trigger_routing_callbacks previous_path: '/parent/child', path: '/parent'

        expect(child.route_from).to eq(1)
        expect(parent.route_to).to eq(0)
        expect(parent.route_from).to eq(0)
      end

      it '/parent/child => /parent/sibling' do
        router.trigger_routing_callbacks previous_path: '/parent/child', path: '/parent/sibling'

        expect(sibling.route_to).to eq(1)
        expect(child.route_from).to eq(1)
        expect(parent.route_to).to eq(0)
        expect(parent.route_from).to eq(0)
      end

      it '/parent => /parent/:id' do
        router.trigger_routing_callbacks previous_path: '/parent', path: '/parent/1'

        expect(dynamic.route_to).to eq(1)
        expect(parent.route_from).to eq(0)
      end

      it '/parent/1 => /parent/2' do
        router.trigger_routing_callbacks previous_path: '/parent/1', path: '/parent/2'
        expect(dynamic.route_to).to eq(1)
        expect(dynamic.route_from).to eq(1)
      end

      it '/parent/1 => /parent' do
        router.trigger_routing_callbacks previous_path: '/parent/1', path: '/parent'

        expect(dynamic.route_from).to eq(1)
        expect(parent.route_to).to eq(0)
      end

      it '/parent/1 => /parent/1/dynamic_child' do
        router.trigger_routing_callbacks previous_path: '/parent/1', path: '/parent/1/dynamic_child'

        expect(dynamic_child.route_to).to eq(1)
        expect(dynamic.route_from).to eq(0)
      end

      it '/parent/1 => /parent/2/dynamic_child' do
        router.trigger_routing_callbacks previous_path: '/parent/1', path: '/parent/2/dynamic_child'

        expect(dynamic_child.route_to).to eq(1)
        expect(dynamic.route_from).to eq(1)
        expect(dynamic.route_to).to eq(1)
      end

      it '/parent/1/dynamic_child => /parent/2/dynamic_child' do
        router.trigger_routing_callbacks previous_path: '/parent/1/dynamic_child', path: '/parent/2/dynamic_child'

        expect(dynamic_child.route_from).to eq(1)
        expect(dynamic_child.route_to).to eq(1)
        expect(dynamic.route_from).to eq(1)
        expect(dynamic.route_to).to eq(1)
      end
    end
  end
end
