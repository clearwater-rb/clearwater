require 'clearwater/binding'
require 'clearwater/event'

module Clearwater
  class Component
    attr_reader :options, :events, :renderer

    def self.template template_name
      @template_name = template_name
    end

    def self.template_name
      @template_name
    end

    def self.attributes *args
      Array(args).each do |attr|
        attr_reader attr

        define_method "#{attr}=" do |new_value|
          instance_variable_set "@#{attr}", new_value

          @bindings[attr].each(&:call)
          @bindings[attr].delete_if(&:dead?)

          renderer.remove_dead_events
          renderer.add_events_to_dom { |event|
            event.reset_binding? @bindings[attr]
          }
        end
      end
    end

    def initialize options={}
      @options = options
      @template = Template[self.class.template_name]
      raise "No template for #{self.class}" unless @template

      @tag_name = 'div'
      @class_name = 'clearwater-component'

      @bindings = Hash.new { |h, k| h[k] = [] }
      @renderer = options[:renderer]
      @events = []
    end

    def event event_type, target_selector, &block
      event = Clearwater::Event.new("##{element_id}", event_type, target_selector, &block)
      events << event
    end

    def render(renderer: Renderer.new)
      element.html = output = to_html(renderer)
      renderer.add_events_to_dom
      output
    end

    def to_html(renderer: renderer)
      renderer.add_events events
      "<#@tag_name id=#{element_id.inspect} class=#{@class_name.inspect}>#{inner_html(renderer: renderer)}</#@tag_name>"
    end

    def to_s
      to_html(renderer: renderer)
    end

    def inner_html(renderer: renderer)
      with_renderer renderer do
        @template.render(self)
      end
    end

    def with_renderer renderer
      old_renderer = @renderer
      @renderer = renderer
      output = yield
      @renderer = old_renderer

      output
    end

    def bind model, property, &block
      binding = model.add_binding property, &block
      binding.to_html
    end

    def bind_attribute attribute, &block
      binding = Binding.new(self, attribute, &block)
      @bindings[attribute].delete_if(&:dead?)
      @bindings[attribute] << binding
      binding.to_html
    end

    def remove_binding attribute, binding
      binding_set = @bindings[attribute]
      binding_set.delete binding
    end

    def element_id
      "#{self.class.name}-#{object_id}-component"
    end

    def element
      Element["##{element_id}"]
    end

    def method_missing *args, &block
      if args.one? && @options.key?(args.first) && !block_given?
        options[args.first]
      else
        raise NoMethodError, "no method #{args.shift}(#{args.join(',')}) for #{self.class}"
      end
    end
  end
end

