module Clearwater
  module CachedRender
    def self.included base
      %x{
        Opal.defn(self, 'type', 'Thunk');
        Opal.defn(self, 'render', function(prev) {
          var self = this;
          var should_render;

          if(prev && prev.vnode && #{!should_render?(`prev`)}) {
            return prev.vnode;
          } else {
            return #{sanitize_content(render)};
          }
        });
      }
    end

    def should_render? _
      false
    end
  end
end
