require 'clearwater/browser/http/request'
require 'pp'

module Clearwater
  module Browser
    module HTTP
      describe Request do
        context :get do
          it 'knows its a GET request' do
            request = Request.new(:get, 'example.com')
            expect(request).to be_get
          end
        end

        context :post do
          it 'knows it is a POST request' do
            request = Request.new(:post, 'example.com')
            expect(request).to be_post
          end
        end
      end
    end
  end
end
