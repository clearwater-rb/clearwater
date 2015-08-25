require 'spec_helper'
require 'clearwater/black_box_node'
require 'clearwater/component'

module Clearwater
  describe BlackBoxNode do
    let(:object) {
      Class.new do
        include Clearwater::BlackBoxNode

        def node
          Clearwater::Component.div({ id: 'foo' }, 'hi')
        end
      end.new
    }

    it 'just renders the specified node' do
      expect(object.to_s).to eq '<div id="foo">hi</div>'
    end
  end
end
