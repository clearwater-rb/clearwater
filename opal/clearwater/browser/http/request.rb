require 'clearwater/browser/http/response'
require 'clearwater/browser/http/event'

module Clearwater
  module Browser
    module HTTP
      class Request
        attr_reader :method, :url, :data, :headers, :promise
        attr_accessor :response

        UNSENT           = 0
        OPENED           = 1
        HEADERS_RECEIVED = 2
        LOADING          = 3
        DONE             = 4

        def initialize(method, url, native: `new XMLHttpRequest()`)
          @native = native
          @method = method
          @url = url

          @ready_state_callbacks = []
          %x{
            #@native.onreadystatechange = #{
              proc do |event|
                @ready_state_callbacks.each do |callback|
                  callback.call event
                end
              end
            }
          }

          @response = Response.new(@native)
        end

        def on event_name, &block
          handler = proc { |event| block.call(Event.new(event)) }
          case event_name
          when :readystatechange
            @ready_state_callbacks << handler
          when :success
            @ready_state_callbacks << proc { |event|
              block.call Event.new(event) if done? && response.success?
            }
          else
            object = post? ? `#@native.upload` : @native
            `object.addEventListener(event_name, handler)`
          end

          self
        end

        def send(data: {}, headers: {})
          `#@native.open(#{method}, #{url})`
          @data = data
          @headers = headers
          headers.each do |attr, value|
            `#@native.setRequestHeader(attr, value)`
          end
          if method == :get || method == :delete
            `#@native.send()`
          else
            `#@native.send(#{JSON.generate data})`
          end

          self
        end

        def post?
          method == :post
        end

        def get?
          method == :get
        end

        def ready_state
          `#@native.readyState`
        end

        def sent?
          ready_state >= OPENED
        end

        def headers_received?
          ready_state >= HEADERS_RECEIVED
        end

        def loading?
          ready_state == LOADING
        end

        def done?
          ready_state >= DONE
        end
      end
    end
  end
end
