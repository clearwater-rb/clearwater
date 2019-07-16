module Clearwater
  module CachedRender
    class Wrapper
      attr_reader :content

      def initialize content
        @content = content
        @key = content.key if content.key
      end

      # Hook into vdom diff/patch
      %x{
        Opal.def(self, 'type', 'Thunk');
        Opal.def(self, 'render', function cached_render(prev) {
          var self = this;

          if(prev && prev.vnode && #{!@content.should_render?(`prev.content`)}) {
            #{ @content = `prev.content` }
            return prev.vnode;
          } else {
            var content = #{Component.sanitize_content(@content.render)};

            while(content && content.type == 'Thunk' && content.render) {
              content = #{Component.sanitize_content(`content.render(prev)`)};
            }

            return content;
          }
        });
      }
    end
  end
end
