require 'browser'
require 'browser/delay'
require 'browser/event'
require 'browser/animation_frame'
require 'clearwater/router'
require 'clearwater/application_registry'
require 'native'

module Clearwater
  class Application
    AppRegistry = ApplicationRegistry.new

    attr_reader :router, :component, :api_client, :on_render

    def self.render
      AppRegistry.render_all
    end

    def initialize options={}
      @router     = options.fetch(:router)     { Router.new }
      @component  = options.fetch(:component)  { nil }
      @element    = options.fetch(:element)    { nil }
      @document   = options.fetch(:document)   { $document }
      @window     = options.fetch(:window)     { $window }
      @on_render  = []

      router.application = self
      component.router = router if component

      @document.on 'visibilitychange' do
        if @render_on_visibility_change
          @render_on_visibility_change = false
          render
        end
      end
    end

    def call &block
      AppRegistry << self
      render_current_url &block
      watch_url
    end

    def watch_url
      unless @watching_url
        @window.on('popstate') { render_current_url }
        @watching_url = true
      end
    end

    def render_current_url &block
      router.set_outlets
      render &block
    end

    def render &block
      on_render << block if block
      return if @will_render
      @will_render = true

      # If the app isn't being shown, wait to render until it is.
      if `!!#@document.hidden`
        @render_on_visibility_change = true
        return
      end

      animation_frame { perform_render }

      nil
    end

    def element
      @element ||= @document.body ? @document.body : nil
    end

    def benchmark message
      if debug?
        start = `performance.now()`
        result = yield
        finish = `performance.now()`
        puts "#{message} in #{(finish - start).round(3)}ms"
        result
      else
        yield
      end
    end

    def debug?
      !!@debug
    end

    def debug!
      @debug = true
    end

    def perform_render
      if element.nil?
        raise TypeError, "Cannot render to a non-existent element. Make sure the document ready event has been triggered before invoking the application."
      end

      rendered = benchmark('Generated virtual DOM') { component.render }
      benchmark('Rendered to actual DOM') { virtual_dom.render rendered }
      @last_render = Time.now
      @will_render = false
      run_callbacks
      nil
    end

    def virtual_dom
      @virtual_dom ||= VirtualDOM::Document.new(element)
    end

    def run_callbacks
      on_render.each(&:call)
      on_render.clear
    end
  end
end
