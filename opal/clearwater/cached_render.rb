module Clearwater
  module CachedRender
    def cached_render
      if !@cached_render || should_render?
        @cached_render = sanitize_content(render)
      else
        @cached_render
      end
    end

    def should_render?
      false
    end
  end
end
