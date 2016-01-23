require 'clearwater/dom_reference'

module Clearwater
  describe DOMReference do
    let(:ref) { DOMReference.new }

    it 'delegates to the DOM node passed in on mount' do
      r = ref

      `r.hook({ value: 'hi' })`

      expect(r.value).to eq 'hi'
    end
  end
end
