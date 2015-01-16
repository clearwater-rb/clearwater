require 'template'
require 'opal-jquery'

module Clearwater
  class View
    attr_accessor :controller

    def initialize options={}
      @element_selector = options.fetch(:element) { self.class.element }
      @template = Template[options.fetch(:template) { self.class.template }]
    end

    def element
      @element || Element[@element_selector]
    end

    def template
      @template
    end

    def render
      element.html = render_html
    end

    def render_html
      template.render(self)
    end

    def event event_name, *args, &block
      selector = "#@element_selector #{args.join(',')}" 

      # Running this on the body rather than the view's element will keep the
      # events active after it is removed from the DOM. I don't know if this
      # is a good idea, but it's working for now. If it ends up slowing down
      # the app, we can go back to putting the event handlers directly on the
      # elements every time we render.
      Element['body'].on event_name, selector do |event|
        instance_exec(event, &block)
      end
    end

    def bind model, property, &block
      model.add_binding property, self, &block
      "<span id='model-#{model.object_id}-#{property}'>#{yield}</span>"
    end

    def self.template *args
      if args.any?
        @template = args.first
      else
        @template
      end
    end

    def self.element *args
      if args.any?
        @element = args.first
      else
        @element
      end
    end

    def root_path
      '/'
    end

    def link_to text, path=nil, attributes={}
      "<a href='#{path}'" + attributes.map { |attr, value|
        " #{attr}=#{value.inspect}"
      }.join + ">#{text}</a>"
    end

    def outlet
      controller && controller.call_outlet
    end

    def router
      controller && controller.router
    end

    def html_escape *args
      ERB::Util.html_escape *args
    end
    alias h html_escape

    def simple_format text
      text.split("\n\n").map {|paragraph| "<p>#{paragraph}</p>" }.join.gsub("\n", '<br/>')
    end

    def method_missing *args, &block
      if args.first.to_s.end_with? '_path'
        router.public_send *args, &block
      else
        controller.public_send *args, &block
      end
    end
  end
end
