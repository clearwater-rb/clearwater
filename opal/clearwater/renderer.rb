module Clearwater
  class Renderer
    attr_reader :events

    def initialize
      @events = []
    end

    def add_events new_events
      events.concat Array(new_events)
    end

    def add_events_to_dom &block
      events = if block_given?
                 self.events.select(&block)
               else
                 self.events
               end

      events.each(&:set_browser_event)
    end

    def remove_dead_events
      events.delete_if { |e| Element[e.view_selector].none? }
    end
  end
end
