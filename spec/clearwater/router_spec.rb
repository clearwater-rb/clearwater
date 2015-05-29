require 'clearwater/router'

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
      expect(router.params_for_path('/articles/foo')).to eq article_id: 'foo'
    end
  end
end
