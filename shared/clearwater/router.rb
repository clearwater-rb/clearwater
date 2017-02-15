require "clearwater/router/route_collection"

module Clearwater
  class Router
    attr_reader :window, :location, :history
    attr_accessor :application

    def initialize options={}, &block
      if RUBY_ENGINE == 'opal'
        @window   = options.fetch(:window)   { Bowser.window  }
        @location = options.fetch(:location) { window.location }
        @history  = options.fetch(:history)  { window.history }
      else
        @location = options.fetch(:location)
      end
      @routes   = RouteCollection.new(self)
      @application = options[:application]

      add_routes(&block) if block_given?
    end

    def add_routes &block
      @routes.instance_exec(&block)
    end

    def routes_for_path path
      parts = get_path_parts(path)
      @routes[parts]
    end

    def canonical_path_for_path path
      routes_for_path(path).map { |r|
        namespace = r.namespace
        "#{"/#{namespace}" if namespace}/#{r.key}"
      }.join
    end

    def targets_for_path path
      routes_for_path(path).map(&:target)
    end

    def params path=current_path
      path_parts = get_path_parts(path)
      canonical_parts = get_path_parts(canonical_path_for_path(path))

      canonical_parts.each_with_index.reduce({}) { |params, (part, index)|
        if part.start_with? ":"
          param = part[1..-1]
          params[param] = path_parts[index]
        end

        params
      }
    end

    def canonical_path
    end

    def nested_routes
      @routes
    end

    def current_path
      location.path
    end

    def self.current_path
      location.path
    end

    def current_url
      location.href
    end

    def self.current_url
      location.href
    end

    def self.location
      Bowser.window.location
    end

    def navigate_to path
      self.class.previous_path = current_path
      history.push path
      set_outlets
      render_application
    end

    def self.navigate_to path
      self.previous_path = current_path
      Bowser.window.history.push path
      render_all_apps
    end

    def self.previous_path=(path)
      @previous_path = path
    end

    def self.previous_path
      @previous_path.to_s
    end

    def navigate_to_remote path
      location.href = path
    end

    def back
      history.back
    end

    def trigger_routing_callbacks(path:, previous_path:)
      # If the paths are the same, there are no callbacks to trigger
      return if path == previous_path

      targets = targets_for_path(path)
      old_targets = targets_for_path(previous_path)
      routes = routes_for_path(path)
      old_params = params(previous_path)
      new_params = params(path)

      changed_dynamic_segments = new_params
        .select { |k, v| old_params[k] != v }
        .map { |key, _| ":#{key}" }

      changed_dynamic_targets = routes.drop_while { |route|
        !changed_dynamic_segments.include?(route.key)
      }.map(&:target)

      navigating_from = old_targets - targets
      navigating_to = targets - old_targets

      (navigating_from | changed_dynamic_targets).each do |target|
        target.on_route_from if target.respond_to? :on_route_from
      end

      (navigating_to | changed_dynamic_targets).each do |target|
        target.on_route_to if target.respond_to? :on_route_to
      end
    end

    def set_outlets targets=targets_for_path(current_path)
      trigger_routing_callbacks(path: current_path, previous_path: self.class.previous_path)

      if targets.any?
        (targets.count).times do |index|
          targets[index].outlet = targets[index + 1]
        end

        application && application.component.outlet = targets.first
      else
        application && application.component.outlet = nil
      end
    end

    private

    def get_path_parts path
      path.split("/").reject(&:empty?)
    end

    def render_application
      if application && application.component
        application.component.call
      end
    end

    def self.render_all_apps
      Clearwater::Application.render
    end
  end
end
