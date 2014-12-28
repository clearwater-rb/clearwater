require 'clearwater/store'
require 'clearwater/router'
require 'clearwater/controller'
require 'clearwater/view'

module Clearwater
  class Application
    attr_reader :store, :router, :controller

    def initialize options={}
      @store      = options.fetch(:store)      { Store.new }
      @router     = options.fetch(:router)     { Router.new }
      @controller = options.fetch(:controller) { ApplicationController.new }

      router.application = self
      controller.router = router
    end

    def call
      router.set_outlets
      controller.call
      trap_clicks
      watch_url
    end

    def trap_clicks
      Element['body'].on :click, 'a' do |event|
        href = event.current_target[:href]
        event.prevent_default unless href.to_s =~ %r{^\w+://}

        if href.nil? || href.empty?
          # Do nothing. There is nowhere to go.
        elsif href == router.current_path
          # Do nothing. We clicked a link to right here.
        elsif href.to_s =~ %r{^\w+://}
          # Don't try to route remote URLs
        else
          router.navigate_to href
        end
      end

      def watch_url
        @path = router.current_path
        check_rerender = proc do
          if @path != router.current_path
            router.set_outlets
            controller && controller.call
            @path = router.current_path
          end
        end
        set_interval = Native(`window.setInterval`)
        set_interval.call check_rerender, 100
      end
    end
  end
end
