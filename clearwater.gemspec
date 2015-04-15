# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
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

  spec.add_runtime_dependency "opal", "0.7.0"
  spec.add_runtime_dependency "opal-jquery", "0.3.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
