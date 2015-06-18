require 'clearwater/component'
require 'browser/history'

# TODO: Remove this once opal-browser supports coordinates natively
# for touch events.
module Browser
  class Event
    class Touch
      def x
        `#@native.pageX`
      end

      def y
        `#@native.pageY`
      end
    end
  end
end

class Link
  include Clearwater::Component

  attr_reader :attributes, :content

  def initialize(attributes={}, content=nil)
    # Augment the onclick passed in by the user, don't replace it.
    @onclick = attributes.dup.delete(:onclick)
    @attributes = attributes.merge(
      onclick: method(:handle_click),
      ontouchstart: method(:handle_touch),
      key: attributes[:href]
    )

    check_active attributes[:href]

    @content = content
  end

  def handle_click event
    if @onclick
      @onclick.call event
    end

    if touch?
      event.prevent
      return
    end

    if event.prevented?
      warn "You are preventing the default behavior of a `Link` component. " +
           "In this case, you could just use an `a` element."
    else
      navigate event
    end
  end

  def handle_touch event
    # All links will treat this as touch because this is a touch device
    @@touch = true
    moved = false
    x_start = event.x
    y_start = event.y

    touch_move_handler = proc do |event|
      x_now = event.x
      y_now = event.y

      # Count this gesture as a non-click if user moves over 30px
      if ((x_now - x_start) ** 2 + (y_now - y_start) ** 2) ** 0.5 > 30
        moved = true
      end
    end

    touch_end_handler = proc do
      unless moved
        @onclick.call event if @onclick
        navigate event
      end

      $document.off 'touchmove', &touch_move_handler
      $document.off 'touchend', &touch_end_handler
    end

    $document.on 'touchmove', &touch_move_handler
    $document.on 'touchend', &touch_end_handler
  end

  def navigate event
    # Don't handle middle-button clicks and clicks with modifier keys. Let them
    # pass through to the browser's default handling or the user's modified handling.
    unless event.meta? || event.shift? || event.ctrl? || event.alt? || (event.respond_to?(:button) && event.button == 1)
      event.prevent
      if href != $window.location.path
        $window.history.push href
        call
        $window.scroll.to x: 0, y: 0
      end
    end
  end

  def href
    attributes[:href]
  end

  def render
    a(attributes, content)
  end

  def touch?
    !!@@touch
  end

  def check_active href
    if $window.location.path == href
      class_name = (
        @attributes.delete(:class_name) ||
        @attributes.delete(:class) ||
        @attributes.delete(:className)
      ).to_s

      @attributes[:className] = "#{class_name} active"
    end
  end
end
