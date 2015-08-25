require 'clearwater/dom_reference'

module Clearwater
  describe DOMReference do
    let(:ref) { DOMReference.new }

    it 'sanitizes to an empty string' do
      expect(ref.to_s).to eq ''
    end
  end
end
