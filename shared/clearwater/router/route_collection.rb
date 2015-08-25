require "clearwater/router/route"

module Clearwater
  class Router
    class RouteCollection
      attr_reader :router

      def initialize parent
        @routes = []
        @parent = parent
        @router = loop do
          break parent if parent.is_a? Router
          parent = parent.parent
        end
      end

      def route route_options, &block
        route_key = route_options.keys.first.to_s
        target = route_options.delete(route_key)
        target.router = router
        options = {
          key: route_key,
          target: target,
          parent: parent,
        }.merge(route_options)
        route = Route.new(options)
        route.instance_exec(&block) if block_given?
        @routes << route
      end

      def namespace *args
        path = args.first
        if path
          @namespace = path
        end

        @namespace
      end

      def [] route_names
        if route_names.any? && route_names.first == @namespace
          route_names = route_names[1..-1]
        end
        routes = @routes.map { |r|
          r.match route_names.first, route_names[1..-1]
        }
        routes.compact!
        routes.flatten!
        routes
      end

      private

      attr_reader :parent
    end
  end
end
