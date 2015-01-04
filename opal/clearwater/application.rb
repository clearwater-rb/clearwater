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
      render_current_url
      trap_clicks
      watch_url
    end

    def trap_clicks
      Element['body'].on :click, 'a' do |event|
        remote_url = %r{^\w+://|^//}
        href = event.current_target[:href]
        event.prevent_default unless href.to_s =~ remote_url

        if href.nil? || href.empty?
          # Do nothing. There is nowhere to go.
        elsif href == router.current_path
          # Do nothing. We clicked a link to right here.
        elsif href.to_s =~ remote_url
          # Don't try to route remote URLs
        else
          router.navigate_to href
        end
      end
    end

    def watch_url
      check_rerender = proc do
        render_current_url
      end

      %x{ window.onpopstate = check_rerender }
    end

    def render_current_url
      router.set_outlets
      controller && controller.call
    end
  end
end
