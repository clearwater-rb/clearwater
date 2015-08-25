require 'spec_helper'
require_relative '../../lib/clearwater/component'

module Clearwater
  RSpec.describe Component do
    let(:component) { Class.new { include Clearwater::Component }.new }

    it 'generates html' do
      html = component.div({ id: 'foo', class_name: 'bar' }, [
        component.p("baz"),
      ]).to_s

      expect(html).to eq('<div id="foo" class="bar"><p>baz</p></div>')
    end

    it 'converts styles into strings' do
      html = component.div({
        style: {
          font_size: '24px',
          padding: '3px',
        }
      }, "Hello world!").to_s

      expect(html).to eq('<div style="font-size:24px;padding:3px">Hello world!</div>')
    end

    it 'removes DOMReference attributes' do
      html = component.div({
        ref: DOMReference.new,
      }, 'Hello World!').to_s

      expect(html).to eq('<div>Hello World!</div>')
    end

    describe 'content sanitization' do
      it 'sanitizes content strings, but not elements' do
        html = component.div(component.p('<em>hi</em>')).to_s

        expect(html).to eq '<div><p>&lt;em>hi&lt;/em></p></div>'
      end
    end
  end
end
