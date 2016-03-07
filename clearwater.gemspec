# -*- encoding: utf-8 -*-
# stub: clearwater 1.0.0.beta5 ruby lib

Gem::Specification.new do |s|
  s.name = "clearwater"
  s.version = "1.0.0.beta5"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jamie Gaskins"]
  s.date = "2016-03-07"
  s.description = "Front-end Ruby web framework for fast, reasonable, and composable applications"
  s.email = ["jgaskins@gmail.com"]
  s.files = ["lib/clearwater", "lib/clearwater.rb", "lib/clearwater/version.rb", "opal/clearwater", "opal/clearwater.rb", "opal/clearwater/application.rb", "opal/clearwater/application_registry.rb", "opal/clearwater/black_box_node.rb", "opal/clearwater/cached_render.rb", "opal/clearwater/component.rb", "opal/clearwater/dom_reference.rb", "opal/clearwater/link.rb", "opal/clearwater/router", "opal/clearwater/router.rb", "opal/clearwater/router/route.rb", "opal/clearwater/router/route_collection.rb", "opal/clearwater/svg_component.rb", "opal/clearwater/virtual_dom", "opal/clearwater/virtual_dom.rb", "opal/clearwater/virtual_dom/js", "opal/clearwater/virtual_dom/js/virtual_dom.js", "spec/clearwater", "spec/clearwater/application_spec.rb", "spec/clearwater/black_box_node_spec.rb", "spec/clearwater/cached_render_spec.rb", "spec/clearwater/dom_reference_spec.rb", "spec/clearwater/router_spec.rb", "spec/component_spec.rb"]
  s.homepage = "https://clearwater-rb.github.io/"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Front-end Ruby web framework for fast, reasonable, and composable applications"
  s.test_files = ["spec/clearwater", "spec/clearwater/application_spec.rb", "spec/clearwater/black_box_node_spec.rb", "spec/clearwater/cached_render_spec.rb", "spec/clearwater/dom_reference_spec.rb", "spec/clearwater/router_spec.rb", "spec/component_spec.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<opal>, ["~> 0.7"])
      s.add_runtime_dependency(%q<bowser>, ["~> 0.1.2"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<opal-rspec>, ["~> 0.5.0.beta2"])
      s.add_development_dependency(%q<rake>, ["~> 10.1"])
      s.add_development_dependency(%q<pry>, ["~> 0.9"])
    else
      s.add_dependency(%q<opal>, ["~> 0.7"])
      s.add_dependency(%q<bowser>, ["~> 0.1.2"])
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<opal-rspec>, ["~> 0.5.0.beta2"])
      s.add_dependency(%q<rake>, ["~> 10.1"])
      s.add_dependency(%q<pry>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<opal>, ["~> 0.7"])
    s.add_dependency(%q<bowser>, ["~> 0.1.2"])
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<opal-rspec>, ["~> 0.5.0.beta2"])
    s.add_dependency(%q<rake>, ["~> 10.1"])
    s.add_dependency(%q<pry>, ["~> 0.9"])
  end
end
