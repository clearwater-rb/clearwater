require 'clearwater/binding'

module Clearwater
  class Model
    def initialize attributes={}
      @_bindings = Hash.new { |h,k| h[k] = [] }
      self.class.attributes.each do |attr|
        public_send "#{attr}=", attributes[attr]
      end
    end

    def add_binding attribute, &block
      binding = Binding.new(self, attribute, &block)
      @_bindings[attribute].delete_if(&:dead?)
      @_bindings[attribute] << binding
      binding
    end

    def self.attributes *args
      @attributes ||= []
      args.each do |attr|
        attr_reader attr

        define_method "#{attr}=" do |value|
          instance_variable_set "@#{attr}", value
          @_bindings[attr].each(&:call)
          @_bindings[attr].delete_if(&:dead?)
        end
      end
      @attributes.concat args
    end
  end
end
