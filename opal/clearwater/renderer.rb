module Clearwater
  class Renderer
    attr_reader :events

    def initialize
      @events = []
    end

    def add_events new_events
      events.concat Array(new_events)
    end

    def add_events_to_dom
      events.each(&:set_browser_event)
    end
  end
end
