require 'clearwater'
require 'clearwater/svg_component'
require 'clearwater/browser'

module Clearwater
  RSpec.describe Application do
    let(:app) {
      Application.new(
        component: component,
        element: element,
      )
    }
    let(:component) {
      $svg_component = self.svg_component
      Class.new do
        include Clearwater::Component

        def render
          div([
            p({ class_name: 'foo' }, 'Hello world'),
            $svg_component,
          ])
        end
      end.new
    }
    let(:svg_component) {
      Class.new do
        include Clearwater::SVGComponent

        def render
          svg({ view_box: '0 0 120 120' }, [
            circle(cx: 50, cy: 50, r: 30),
          ])
        end
      end.new
    }
    let(:element) { Clearwater::Browser::Document.create_element('div') }

    it 'renders to the specified element' do
      app.perform_render

      expect(element.inner_html).to eq '<div><p class="foo">Hello world</p><svg viewBox="0 0 120 120"><circle cx="50" cy="50" r="30"></circle></svg></div>'
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
