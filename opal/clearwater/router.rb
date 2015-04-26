require "clearwater/router/route_collection"

module Clearwater
  class Router
    attr_reader :window, :location, :history
    attr_accessor :application

    def initialize options={}, &block
      @window   = options.fetch(:window)   { Native(`window`)  }
      @location = options.fetch(:location) { window[:location] }
      @history  = options.fetch(:history)  { window[:history]  }
      @routes   = RouteCollection.new(self)
      @application = options[:application]

      add_routes(&block) if block_given?
    end

    def add_routes &block
      @routes.instance_exec(&block)
    end

    def routes_for_path path
      parts = path.split("/").reject(&:empty?)
      @routes[parts]
    end

    def canonical_path_for_path path
      routes_for_path(path).map { |r| "/#{r.key}" }.join
    end

    def targets_for_path path
      routes_for_path(path).map(&:target)
    end

    def params_for_path path
      path_parts = path.split("/").reject(&:empty?)
      canonical_parts = canonical_path_for_path(path).split("/").reject(&:empty?)
      params = {}
      canonical_parts.each_with_object(params)
                     .each_with_index { |(part, params), index|
        if part.start_with? ":"
          param = part[1..-1].to_sym
          params[param] = path_parts[index]
        end
      }
      params
    end

    def canonical_path
    end

    def current_path
      location[:pathname]
    end

    def navigate_to path
      push_state path
      set_outlets
      render_application
    end

    def navigate_to_remote path
      location[:href] = path
    end

    def current_url
      location[:href]
    end

    def back
      history.back
    end

    def set_outlets targets=targets_for_path(current_path)
      if targets.any?
        (targets.count - 1).times do |index|
          targets[index].outlet = targets[index + 1]
        end
        targets.last.default_outlet!

        application && application.controller.outlet = targets.first
      else
        application && application.controller.default_outlet!
      end
    end

    private

    def push_state path
      history.pushState({}, nil, path)
    end

    def render_application
      if application && application.controller
        application.controller.call
      end
    end
  end
end
