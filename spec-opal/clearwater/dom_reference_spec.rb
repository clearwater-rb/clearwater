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
  end
end
