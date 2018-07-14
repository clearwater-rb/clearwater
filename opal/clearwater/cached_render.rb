require 'clearwater/component'

module Clearwater
  module CachedRender
    def self.included base
      %x{
        Opal.defn(self, '$$cached_render', true);
      }
    end

    def should_render? _
      false
    end

    def key
    end
  end
end
