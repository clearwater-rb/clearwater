#!/usr/bin/env ruby

lib = File.expand_path(File.join("..", "lib"), __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "clearwater/version"

Gem::Specification.new do |spec|
  spec.name = "clearwater"
  spec.version = Clearwater::VERSION
  spec.authors = ["Jamie Gaskins"]
  spec.email = ["jgaskins@gmail.com"]
  spec.summary = %q{Front-end web framework built on Opal}
  spec.description = spec.summary
  spec.homepage = "https://clearwater-rb.github.io/"
  spec.license = "MIT"

  spec.files = Dir[File.join("lib", "**", "*"), File.join("opal", "**", "*")]
  spec.executables = Dir[File.join("bin", "**", "*")].map! { |f| f.gsub(/bin\//, "") }
  spec.test_files = Dir[File.join("test", "**", "*"), File.join("spec", "**", "*")]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "opal", "~> 0.7"
  spec.add_runtime_dependency 'opal-browser'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "opal-rspec", "~> 0.5.0.beta2"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "pry", "~> 0.9"
  spec.add_development_dependency "pry-doc", "~> 0.6"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4"
end
