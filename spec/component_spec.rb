require 'clearwater/component'

# When running specs from the CLI, it doesn't define this class
unless defined? Browser::Event
  module Browser
    class Event
      def initialize event
      end
    end
  end
end

module Clearwater
  RSpec.describe Component do
    let(:component_class) {
      Class.new do
        include Clearwater::Component
      end
    }
    let(:component) { component_class.new }

    it 'provides a default render method' do
      expect(component.render).to be_nil
    end

    Component::HTML_TAGS.each do |tag|
      it "provides helpers for `#{tag}` elements" do
        expect(`#{component.send(tag)}.tagName`).to eq tag.upcase
      end
    end

    it 'sanitizes element attributes' do
      attributes = Component.sanitize_attributes({
        class: 'foo',
        onclick: proc { |event| expect(event).to be_a Browser::Event },
      })

      # Renames :class to :class_name
      expect(attributes[:class_name]).to eq 'foo'

      # Wraps yielded events in a Browser::Event
      attributes[:onclick].call(`document.createEvent('MouseEvent')`)
    end

    describe 'sanitizing content' do
      it 'sanitizes components by calling `render`' do
        allow(component).to receive(:render) { 'foo' }
        expect(Component.sanitize_content(component)).to eq 'foo'
      end

      it 'sanitizes arrays by sanitizing each element' do
        allow(component).to receive(:render) { 'foo' }
        expect(Component.sanitize_content([component, nil, 1])).to eq ['foo', nil, 1]
      end
    end

    it 'retrieves params from the router' do
      router = double('Router')
      params = { article_id: 123 }
      allow(router).to receive(:params_for_path) { params }
      allow(router).to receive(:current_path) { '/articles/123' }
      component.router = router

      expect(component.params).to eq params
    end
  end
end
