module Clearwater
  class Binding
    def initialize component, attribute, &block
      @attribute = attribute
      @component = component
      @block = block
      @dead = false
    end

    def call
      html = @block.call
      if (e = element).any?
        e.html = html
      else
        dead!
      end
    end

    def to_html
      "<span id=#{id.inspect}>#{@block.call}</span>"
    end

    def element
      Element[selector]
    end

    def selector
      "##{id}"
    end

    def id
      # HTML tag ids can't have '::' in them, apparently.
      @class_name ||= @component.class.name.gsub(/::/, '-')

      "#{@class_name}-#{@component.object_id}-binding-#{object_id}-#{@attribute}"
    end

    def dead?
      @dead
    end

    def dead!
      @dead = true
    end
  end
end
