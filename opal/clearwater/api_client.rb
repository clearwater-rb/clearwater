require "clearwater/cgi"
require "browser/http"

module Clearwater
  class APIClient
    ResponseNotFinished = Class.new(RuntimeError)

    attr_reader :base_url

    def initialize attributes={}
      @base_url = attributes.fetch(:base_url) { nil }
    end

    def fetch resource, id, params
      response = Browser::HTTP.get(path_for_resource(resource, id, params))
      Response.new(response)
    end

    def store resource, id, data={}
      path = case id
             when String, Numeric
               path_for_resource(resource, id)
             when Hash
               data.merge! id
               path_for_resource(resource)
             end

      response = Browser::HTTP.post(path, data)
      Response.new(response)
    end

    def update resource, id, data
      response = Browser::HTTP.patch path_for_resource(resource, id), data: data
      Response.new(response)
    end

    def delete resource, id
      response = Browser::HTTP.delete path_for_resource(resource, id)
      Response.new(response)
    end

    private

    def path_for_resource resource, id, params={}
      path = "#{base_url}/#{resource}"
      case id
      when String, Numeric
        path += "/#{id}"
      when Hash
        params.merge! id
      end

      if params.any?
        path += "?#{query_string(params)}"
      end

      path
    end

    def query_string params
      query_params = params.map { |key, value|
        "#{CGI.escape(key)}=#{CGI.escape(value)}"
      }.join("&")
    end

    class Response
      attr_reader :response

      def initialize response
        @response = response
      end

      def then
        response.then do |r|
          yield self.class.new(r)
        end
      end

      def fail
        response.fail do |r|
          yield self.class.new(r)
        end
      end

      def json
        response.json
      end
    end
  end
end
