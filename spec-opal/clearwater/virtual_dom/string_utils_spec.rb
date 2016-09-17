require 'clearwater/virtual_dom'

module Clearwater
  module VirtualDOM
    describe StringUtils do
      describe :camelize do
        {
          'foo' => 'foo',
          'foo_bar' => 'fooBar',
          'foo_bar_baz' => 'fooBarBaz',
        }.each do |source, target|
          it 'camelizes a string' do
            expect(StringUtils.camelize(source)).to eq target
          end
        end
      end
    end
  end
end
