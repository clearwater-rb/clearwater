require 'clearwater/black_box_node'
require 'clearwater/virtual_dom'

bbn_class = Class.new do
  include Clearwater::BlackBoxNode

  attr_reader :last_update

  def node
    Clearwater::VirtualDOM.node :span, { id: 'foo' }, ['hi']
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

  self
end

module Clearwater
  describe BlackBoxNode do
    let(:object) { bbn_class.new }
    let(:renderable) { object.render }
    let(:node) { `{}` }

    it 'has the special type of "Widget"' do
      r = renderable
      expect(`r.type`).to eq 'Widget'
    end

    it 'uses the delegate node to render into the DOM' do
      r = renderable
      expect(`#{renderable.create_element}['native'].outerHTML`).to eq '<span id="foo">hi</span>'
    end

    it 'calls mount when inserted into the DOM' do
      r = renderable
      `r.init()`
      expect(object).to be_mounted
    end

    it 'calls unmount when removed from the DOM' do
      r = renderable
      `r.init()`
      `r.destroy(#{node})`
      expect(object).not_to be_mounted
    end

    it 'calls update when updated in the DOM' do
      `#{renderable}.update(#{renderable.dup}, #{node})`

      expect(object.last_update).not_to be_nil
    end

    it 'unmounts previous and fresh-mounts new instance on type change' do
      previous = Class.new do
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
          @unmounted = true
        end

        def mounted?
          !!@mounted
        end

        def unmounted?
          !!@unmounted
        end
      end.new
      prev_renderable = BlackBoxNode::Renderable.new(previous)

      previous.mount double # pass in a fake node, we don't care

      `#{renderable}.update(#{prev_renderable}, {})`

      expect(previous).to be_unmounted
      expect(object).to be_mounted
    end
  end
end
