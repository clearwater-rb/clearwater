require 'opal-jquery'

module Clearwater
  class Event
    attr_reader :view_selector, :event_type, :target_selector

    def initialize view_selector, event_type, target_selector=nil, &block
      @view_selector = view_selector
      @event_type = event_type
      @target_selector = target_selector
      @block = block
    end

    def call event
      @block.call event
    end

    def set_browser_event
      selector = "#{view_selector} #{target_selector}"
      Element[selector].on event_type, &@block
    end
  end
end
