require 'clearwater/component'
require 'bowser'

class Link
  include Clearwater::Component

  attr_reader :attributes, :content

  def initialize(attributes={}, content=nil)
    # Augment the onclick passed in by the user, don't replace it.
    @onclick = attributes.dup.delete(:onclick)
    @attributes = attributes.merge(
      onclick: method(:handle_click),
      key: attributes[:href]
    )

    check_active attributes[:href]

    @content = content
  end

  def handle_click event
    if @onclick
      @onclick.call event
    end

    if event.prevented?
      warn "You are preventing the default behavior of a `Link` component. " +
           "In this case, you could just use an `a` element."
    else
      navigate event
    end
  end

  def navigate event
    # Don't handle middle-button clicks and clicks with modifier keys. Let them
    # pass through to the browser's default handling or the user's modified handling.
    modified = (
      event.meta? ||
      event.shift? ||
      event.ctrl? ||
      event.alt? ||
      event.button == 1
    )

    return if modified

    event.prevent
    window = Bowser.window
    if href != window.location.path
      Clearwater::Router.navigate_to href
      window.scroll 0, 0
    end
  end

  def href
    attributes[:href]
  end

  def render
    a(attributes, content)
  end

  def check_active href
    if Bowser.window.location.path == href
      class_name = (
        @attributes.delete(:class_name) ||
        @attributes.delete(:class) ||
        @attributes.delete(:className)
      ).to_s

      @attributes[:className] = "#{class_name} active"
    end
  end
end
