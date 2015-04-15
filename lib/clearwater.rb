require "clearwater/version"
require "opal"
require "opal/jquery"

Opal.append_path(File.expand_path(File.join("..", "..", "opal"), __FILE__).untaint)
