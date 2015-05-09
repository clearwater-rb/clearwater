require 'opal'
require 'clearwater/router'
require 'clearwater/application_registry'
require 'clearwater/virtual_dom_component'
require 'browser'
require 'browser/delay'
require 'clearwater/link'

module Clearwater
  class Application
    RENDER_FPS = 60
    AppRegistry = ApplicationRegistry.new

    attr_reader :store, :router, :component, :api_client

    def self.render
      AppRegistry.render_all
    end

    def initialize options={}
      @store      = options.fetch(:store)      { nil }
      @router     = options.fetch(:router)     { Router.new }
      @component  = options.fetch(:component)  { nil }
      @api_client = options.fetch(:api_client) { nil }
      @element    = options.fetch(:element)    { nil }

      router.application = self
      component.router = router

      $document.on 'visibilitychange' do
        if @render_on_visibility_change
          render
        end
      end
    end

    def call
      AppRegistry << self
      render_current_url
      watch_url
    end

    def watch_url
      unless @watching_url
        @watching_url = true
        $window.on('popstate') { render_current_url }
      end
    end

    def render_current_url
      router.set_outlets
      render
    end

    def render
      # If the app isn't being shown, wait to render until it is.
      if `document.hidden`
        @render_on_visibility_change = true
        return
      end

      # Throttle rendering
      if Time.now - last_render < time_between_renders
        delay_render
      else
        if element.nil?
          raise TypeError, "Cannot render to a non-existent element. Make sure the document ready event has been triggered before invoking the application."
        end

        @_virtual_dom ||= VirtualDOM::Document.new(element)

        rendered = benchmark('Generated virtual DOM') { component.render }
        benchmark('Rendered to actual DOM') { @_virtual_dom.render rendered }
        @last_render = Time.now
      end

      nil
    end

    def element
      @element ||= begin
                     if `document.body != null` || `document.body != undefined`
                       $document.body
                     else
                       nil
                     end
                   end
    end

    def benchmark message
      if debug?
        start = Time.now
        result = yield
        finish = Time.now
        puts "#{message} in #{(finish - start) * 1000}ms"
        result
      else
        yield
      end
    end

    def debug?
      false
    end

    def delay_render
      unless @next_render
        @next_render = last_render + time_between_renders
        now = Time.now
        after [@next_render - now, time_between_renders].max do
          render
          @next_render = nil
        end
      end
    end

    def last_render
      @last_render ||= Time.now - 10
    end

    def time_between_renders
      1 / RENDER_FPS
    end
  end
end
