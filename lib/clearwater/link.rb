require 'clearwater/component'

class Link
  include Clearwater::Component

  def initialize attributes, content
    @attributes = attributes
    @content    = content
  end

  def render
    a(@attributes, @content)
  end
end
