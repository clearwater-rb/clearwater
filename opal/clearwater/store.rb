require 'json'

module Clearwater
  class Store
    attr_reader :mapping, :identity_map

    def initialize options={}
      @url = options.fetch(:url) { "/api/:model/:id" }
      @mapping = Mapping.new(options.fetch(:mapping) { {} })
      @protocol = options.fetch(:protocol) { HTTP }
      @identity_map = IdentityMap.new
    end

    def all klass
      deserialized = api(:get, url_for(klass)).body
      models = JSON.parse(deserialized).map do |attributes|
        deserialize(klass, attributes)
      end
    end

    def find klass, id
      identity_map.fetch(klass, id) do
        serialized = api(:get, url_for(klass, id)).body
        identity_map[klass][id] = deserialize(klass, JSON.parse(serialized))
      end
    end

    def save model
      method = persisted?(model) ? :patch : :post
      response = api method, url_for_model(model)
      if method == :post && response.ok
        attributes = JSON.parse(response.body)
        model.instance_variable_set :@id, attributes[:id]
      end
    end

    def delete model
      api :delete, url_for_model(model)
    end

    def persisted? model
      !!model.id
    end

    private

    def api method, url
      @protocol.public_send method, url
    end

    def url_for klass, id=nil
      @url.gsub(':model', mapping[klass])
          .gsub(':id', id.to_s)
    end

    def url_for_model model
      url_for(model.class, model.id)
    end

    def url_for_class klass, id
      url_for(klass, nil)
    end

    def deserialize klass, attributes
      model = klass.allocate
      attributes.each do |attr, value|
        model.instance_variable_set "@#{attr}", value
      end

      model
    end
  end

  class Mapping
    def initialize mappings={}
      @custom_mappings = mappings
    end

    def [] klass
      @custom_mappings.fetch(klass) { |*args|
        klass.name.downcase.gsub('::', '/') + 's'
      }
    end
  end

  class IdentityMap
    def initialize
      @map = Hash.new { |h, k| h[k] = {} }
    end

    def [] key
      @map[key]
    end

    def fetch(klass, id, &block)
      self[klass].fetch(id, &block)
    end
  end
end
