require 'clearwater/black_box_node'

module Clearwater
  describe BlackBoxNode do
    let(:object) {
      Class.new do
        include Clearwater::BlackBoxNode

        attr_reader :last_update

        def node
          VirtualDOM.node :span, { id: 'foo' }, ['hi']
        end

        def mount node
          @mounted = true
        end

        def update
          @last_update = Time.now
        end

        def unmount
          @mounted = false
        end

        def mounted?
          !!@mounted
        end
      end.new
    }
    let(:renderable) { BlackBoxNode::Renderable.new(object) }

    it 'has the special type of "Widget"' do
      r = renderable
      expect(`r.type`).to eq 'Widget'
    end

    it 'uses the delegate node to render into the DOM' do
      r = renderable
      expect(`#{renderable.create_element}.native.outerHTML`).to eq '<span id="foo">hi</span>'
    end

    it 'calls mount when inserted into the DOM' do
      r = renderable
      `r.init()`
      expect(object).to be_mounted
    end

    it 'calls unmount when removed from the DOM' do
      r = renderable
      `r.init()`
      `r.destroy()`
      expect(object).not_to be_mounted
    end

    it 'calls update when updated in the DOM' do
      r = renderable
      `r.update(#{BlackBoxNode::Renderable.new(object)})`

      expect(object.last_update).not_to be_nil
    end
  end
end
