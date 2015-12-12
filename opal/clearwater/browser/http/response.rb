require 'json'

module Clearwater
  module Browser
    module HTTP
      class Response
        def initialize xhr
          @xhr = xhr
        end

        def code
          `#@xhr.status`
        end

        def body
          `#@xhr.response`
        end

        def json
          body = self.body
          @json ||= JSON.parse(body) if `body !== undefined`
        end

        def success?
          (200...400).cover? code
        end

        def fail?
          !success?
        end
      end
    end
  end
end
