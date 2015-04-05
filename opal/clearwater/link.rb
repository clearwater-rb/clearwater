require 'clearwater/virtual_dom_component'
require 'browser/history'

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

    touch_move_handler = proc do
      moved = true
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
    unless event.meta? || event.shift? || event.ctrl? || event.alt?
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
