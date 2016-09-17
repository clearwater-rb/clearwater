require 'clearwater/virtual_dom'

module Clearwater
  module VirtualDOM
    describe HashUtils do
      let(:hash) do
        {
          src: 'foo',
          omg: nil,
          style: {
            background_color: :blue,
          },
        }
      end
      let(:native) { HashUtils.camelized_native(hash) }

      it 'uses string keys normally' do
        expect(`#{native}.src === 'foo'`).to be_truthy
      end

      it 'converts nil keys to null' do
        expect(`#{native}.omg == null`).to be_truthy
      end

      it 'camelizes sub-hash keys' do
        expect(`#{native}.style.backgroundColor === 'blue'`).to be_truthy
      end
    end
  end
end
