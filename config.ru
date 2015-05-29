require 'bundler'
Bundler.require

require 'opal/rspec'

run Opal::Server.new { |s|
  s.main = 'opal/rspec/sprockets_runner'
  s.append_path 'spec'
  s.debug = false
}
