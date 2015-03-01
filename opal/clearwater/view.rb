require 'clearwater/renderer'
require 'clearwater/event'
require 'template'
require 'opal-jquery'

module Clearwater
  class View
    attr_accessor :controller
    attr_reader :events, :renderer

    def initialize options={}
      @element_selector = options.fetch(:element) { self.class.element }
      @template = Template[options.fetch(:template) { self.class.template }]
      raise "No template for #{self.class}" unless @template
      @events = []
    end

    def element
      @element || Element[@element_selector]
    end

    def template
      @template
    end

    def render renderer=Renderer.new
      output = render_html(renderer)
      renderer.add_events_to_dom

      target_element = Element["##{wrapper_id}"]

      if target_element.none?
        target_element = element
      end

      target_element.html = output
    end

    def render_html renderer
      "<span id=#{wrapper_id.inspect}>#{render_inner_html(renderer)}</span>"
    end

    def render_inner_html(renderer)
      with_renderer renderer do
        renderer.add_events events
        template.render(self)
      end
    end

    def with_renderer renderer
      old_renderer = @renderer
      @renderer = renderer
      output = yield
      @renderer = old_renderer

      output
    end

    def event event_name, *args, &block
      event = Clearwater::Event.new("##{wrapper_id}", event_name, *args, &block)
      events << event
    end

    def wrapper_id
      class_name = self.class.name.gsub(/::/, '-')
      "#{class_name}-#{object_id}-view"
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

    def outlet(renderer=@renderer)
      controller && controller.call_outlet(renderer)
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
      controller.public_send *args, &block
    end
  end
end
