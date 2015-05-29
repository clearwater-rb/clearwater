require "set"

module Clearwater
  class Store
    include Enumerable

    attr_reader :type

    def initialize type
      @type = type
      @models = {}
      @callbacks = Hash.new { |h, k| h[k] = Set.new }
    end

    def deserialize hash
      model = type.allocate
      hash.each do |attr, value|
        model.public_send "#{attr}=", value
      end

      model
    end

    def << model
      @models[model.id] = model
      run_callbacks :add, model
      self
    end

    def [] id
      @models[id]
    end

    def each &block
      @models.each_value(&block)
    end

    def on event_name, &block
      @callbacks[event_name] << block
    end

    private

    def run_callbacks event_name, data=nil
      @callbacks[event_name].each do |callback|
        if data
          callback.call data
        else
          callback.call
        end
      end
    end
  end
end
