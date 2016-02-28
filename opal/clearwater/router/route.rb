require "clearwater/router/route_collection"

module Clearwater
  class Router
    class Route
      attr_reader :target, :key, :parent

      def initialize options={}
        @key = options.fetch(:key)
        @target = options.fetch(:target)
        @parent = options.fetch(:parent)
      end

      def route *args, &block
        nested_routes.route *args, &block
      end

      def canonical_path
        @canonical_path ||= "#{parent.canonical_path}/#{key}".gsub("//", "/")
      end

      def match key, other_parts=[]
        if key && (key == self.key || param_key?)
          if Array(other_parts).any?
            [self, nested_routes[other_parts]]
          else
            self
          end
        end
      end

      def namespace
        parent.nested_routes.namespace
      end

      private

      def param_key?
        @param_key ||= key.start_with? ":"
      end

      def nested_routes
        @nested_routes ||= RouteCollection.new(self)
      end
    end
  end
end
