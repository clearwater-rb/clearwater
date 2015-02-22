require 'clearwater/binding'

module Clearwater
  class Component
    attr_reader :options

    def self.template template_name
      @template_name = template_name
    end

    def self.template_name
      @template_name
    end

    def self.attributes attributes
      Array(attributes).each do |attr|
        attr_reader attr

        define_method "#{attr}=" do |new_value|
          instance_variable_set "@#{attr}", new_value
          @bindings[attr].each(&:call)
          @bindings[attr].delete_if(&:dead?)
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
    end

    def event event_type, target_selector, &block
      document_body.on event_type, "##{element_id} #{target_selector}", &block
    end

    def render
      element.html = to_html
    end

    def to_html
      "<#@tag_name id=#{element_id.inspect} class=#{@class_name.inspect}>#{inner_html}</#@tag_name>"
    end

    def to_s
      to_html
    end

    def inner_html
      @template.render(self)
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
      "#{self.class.name}-#{object_id}"
    end

    def element
      document_body.find("##{element_id}")
    end

    def document_body
      Element[`document.body`]
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

