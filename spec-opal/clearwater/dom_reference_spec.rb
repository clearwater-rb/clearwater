require 'clearwater/dom_reference'

module Clearwater
  describe DOMReference do
    let(:ref) { DOMReference.new }

    it 'delegates to the DOM node passed in on mount' do
      r = ref

      `r.hook({ value: 'hi' })`

      expect(r.value).to eq 'hi'
    end

    it 'knows when it has been mounted' do
      expect(ref).not_to be_mounted

      ref.mount(Object.new)

      expect(ref).to be_mounted
    end

    it 'knows when it is unmounted' do
      ref.mount Object.new
      ref.unmount

      expect(ref).not_to be_mounted
    end

    it 'raises an error if proxied methods are called on it before mount' do
      expect { ref.foo_bar }.to raise_error(TypeError)
    end

    it 'does not pass undefined or null as the previous value' do
      r = Class.new(DOMReference) {
        attr_reader :previous, :next

        def mount element, previous
          super

          @previous = previous
        end

        def unmount element, next_value
          super

          @next = next_value
        end
      }.new

      `r.hook({}, undefined)`
      `r.unhook({}, undefined)`

      expect(`r.previous === nil`).to be_truthy
      expect(`r.next === nil`).to be_truthy
    end
  end
end
