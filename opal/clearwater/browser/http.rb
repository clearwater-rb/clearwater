require 'native'
require 'promise'

require 'clearwater/browser/http/request'

module Clearwater
  module Browser
    module HTTP
      module_function

      def fetch(url)
        promise = Promise.new
        request = Request.new(:get, url)

        request.on :success do
          promise.resolve request.response
        end
        request.on :error do |event|
          promise.reject Native(event)
        end
        request.send

        promise
      end

      def upload(url, data, content_type: 'application/json')
        promise = Promise.new
        request = Request.new(:post, url)

        request.on :success do
          promise.resolve request.response
        end
        request.on :error do |event|
          promise.reject Native(event)
        end
        request.send(data: data, headers: { 'Content-Type' => content_type })

        promise
      end
    end
  end
end
