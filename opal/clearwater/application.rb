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
    end
  end
end
