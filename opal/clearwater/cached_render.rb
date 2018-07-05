module Clearwater
  module CachedRender
    autoload :Wrapper, 'clearwater/cached_render/wrapper'

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
