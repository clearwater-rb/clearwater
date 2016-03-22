require 'clearwater/component'

module Clearwater
  module CachedRender
    def self.included base
      %x{
        Opal.defn(self, 'type', 'Thunk');
        Opal.defn(self, 'render', function(prev) {
          var self = this;

          if(prev && prev.vnode && #{!should_render?(`prev`)}) {
            return prev.vnode;
          } else {
            var content = #{Component.sanitize_content(render)};

            while(content && content.type == 'Thunk' && content.render) {
              content = #{Component.sanitize_content(`content.render(prev)`)};
            }

            return content;
          }
        });
      }
    end

    def should_render? _
      false
    end
  end
end
