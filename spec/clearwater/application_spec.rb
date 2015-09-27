require 'clearwater'

module Clearwater
  RSpec.describe Application do
    let(:app) {
      Application.new(
        component: component,
        element: element,
      )
    }
    let(:component) {
      Class.new do
        include Clearwater::Component

        def render
          h1('Hello world')
        end
      end.new
    }
    let(:element) { $document.create_element('div') }

    it 'renders to the specified element' do
      app.perform_render

      expect(element.inner_html).to eq '<h1>Hello world</h1>'
    end

    it 'calls queued blocks after rendering' do
      i = 1
      app.on_render << proc { i += 1 }
      app.on_render << proc { i += 1 }

      app.perform_render
      expect(i).to eq 3
    end

    it 'empties the block queue after rendering' do
      app.on_render << proc { }

      app.perform_render

      expect(app.on_render).to be_empty
    end
  end
end
