module Clearwater
  class Application
    attr_reader :component, :router

    def initialize options={}
      @router = options.fetch(:router) { Router.new }
      @component = options.fetch(:component) { nil }
      router.application = self
      component.router = router
    end

    def render
      router.set_outlets
      component.to_s
    end
  end
end
