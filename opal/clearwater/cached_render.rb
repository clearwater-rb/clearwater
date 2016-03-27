require 'clearwater/component'

module Clearwater
  module CachedRender
    def self.included base
      %x{
        Opal.defn(base, '$$thunk', true);
      }
    end

    def should_render? _
      false
    end
  end
end
