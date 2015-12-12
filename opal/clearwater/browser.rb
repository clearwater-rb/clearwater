module Clearwater
  module Browser
    module EventTarget
      def on event_name, &block
        if `#@native.addEventListener !== undefined`
          `#@native.addEventListener(event_name, block)`
        elsif `#@native.addListener !== undefined`
          `#@native.addListener(event_name, block)`
        else
          warn "[Clearwater] Not entirely sure how to add an event listener to #{self}"
        end
        self
      end

      def off event_name, &block
        if `#@native.removeEventListener !== undefined`
          `#@native.removeEventListener(event_name, block)`
        elsif `#@native.removeListener !== undefined`
          `#@native.removeListener(event_name, block)`
        else
          warn "[Clearwater] Not entirely sure how to remove an event listener from #{self}"
        end
        self
      end
    end

    module Window
      extend EventTarget

      @native = `window`

      module_function

      if `#@native.requestAnimationFrame !== undefined`
        def animation_frame &block
          `requestAnimationFrame(block)`
          self
        end
      else
        def animation_frame &block
          delay(0.16, &block)
          self
        end
      end

      def delay duration, &block
        `setTimeout(block, duration * 1000)`
        self
      end

      def interval duration, &block
        `setInterval(block, duration * 1000)`
        self
      end

      def location
        Location
      end

      module Location
        module_function

        def path
          `window.location.pathname`
        end
      end
    end

    module Document
      extend EventTarget

      @native = `document`

      module_function

      def body
        @body ||= Element.new(`#@native.body`)
      end

      def [] css
        native = `#@native.querySelector(css)`
        if `#{native} === undefined`
          nil
        else
          Element.new(native)
        end
      end

      def create_element type
        Element.new(`document.createElement(type)`)
      end
    end

    class Element
      include EventTarget

      def initialize native
        @native = native
      end

      def inner_dom= node
        clear
        append node
      end

      def inner_html
        `#@native.innerHTML`
      end

      def clear
        %x{
          var native = #@native;

          if(native.nodeName === 'INPUT' || native.nodeName === 'TEXTAREA') {
            native.value = null;
          } else {
            var children = native.children;
            for(var i = 0; i < children.length; i++) {
              children[i].remove();
            }
          }
        }
        self
      end

      def append node
        `#@native.appendChild(node)`
        self
      end

      # Form input methods
      def checked?
        `!!#@native.checked`
      end

      def value
        `#@native.value`
      end
    end

    class Event
      def initialize native
        @native = native
      end

      def prevent
        `#@native.preventDefault()`
        self
      end

      def prevented?
        `#@native.defaultPrevented`
      end

      def meta?
        `#@native.metaKey`
      end

      def shift?
        `#@native.shiftKey`
      end

      def ctrl?
        `#@native.ctrlKey`
      end

      def alt?
        `#@native.altKey`
      end

      def button
        `#@native.button`
      end

      def target
        Element.new(`#@native.currentTarget`)
      end

      def code
        `#@native.keyCode`
      end
    end
  end
end
