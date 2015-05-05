require 'set'

module Clearwater
  class ApplicationRegistry
    def initialize
      @apps = Set.new
    end

    def << app
      @apps << app
    end

    def render_all
      @apps.each(&:render_current_url)
    end

    def delete app
      @apps.delete app
    end
  end
end
