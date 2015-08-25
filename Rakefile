#!/usr/bin/env rake

require 'bundler/gem_tasks'
require 'bundler/setup'
require 'clearwater'

require 'opal/rspec/rake_task'
Opal.append_path File.expand_path('../spec-opal', __FILE__)
Opal::RSpec::RakeTask.new(:spec_opal) do |server, task|
  task.files = FileList['spec-opal/**/*_spec.rb']
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, :spec_opal]
