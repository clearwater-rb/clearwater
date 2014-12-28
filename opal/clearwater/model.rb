module Clearwater
  class Model
    def initialize attributes={}
      @_bindings = Hash.new { |h,k| h[k] = [] }
      self.class.attributes.each do |attr|
        public_send "#{attr}=", attributes[attr]
      end
    end

    def add_binding attribute, &block
      @_bindings[attribute] << Binding.new(self, attribute, &block)
    end

    def self.attributes *args
      @attributes ||= []
      args.each do |attr|
        attr_reader attr

        define_method "#{attr}=" do |value|
          instance_variable_set "@#{attr}", value
          @_bindings[attr].each(&:call)
        end
      end
      @attributes.concat args
    end

    class Binding
      attr_reader :model, :attribute, :block

      def initialize model, attribute, &block
        @model = model
        @attribute = attribute
        @block = block
      end

      def call
        Element["#model-#{model.object_id}-#{attribute}"].html = block.call
      end
    end
  end
end
