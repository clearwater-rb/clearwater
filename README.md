# Clearwater

Clearwater is a browser MVC framework, similar to Ember.js or Backbone.js. The primary difference is that Clearwater is written in Ruby and compiled using Opal.

## Installation

Add these lines to your application's Gemfile:

```ruby
gem "clearwater", github: "jgaskins/clearwater"
gem "opal-rails" # For asset-pipeline integration
```

You may need to add this line, as well, until a new version of Opal is released:

```ruby
gem "opal-jquery"
```

If you'd like to use Slim or Haml templates, you'll want to add one of these two lines:

```ruby
gem "opal-slim"
gem "opal-haml", github: "opal/opal-haml" # Released gem is outdated
```

And then execute:

    $ bundle

## Usage

Clearwater targets the Rails asset pipeline, so it will work best in a Rails app. It may work fine with other server-side web frameworks, but I haven't tried it yet.

### Create your application

#### app/assets/javascripts/application.rb

```ruby
# Load Clearwater
require "clearwater/application"

# Pick one of these two depending on which template engine you like most.
require "opal-haml"
require "opal-slim"

# You have to load your templates.
require "templates/application"

class ApplicationController < Clearwater::Controller
  view { Clearwater::View.new(element: "#app", template: "application") }
end

MyApp = Clearwater::Application.new(
  controller: ApplicationController.new
)

# Run the app when document ready event fires
Document.ready? do
  MyApp.call
end
```

#### app/assets/javascripts/templates/application.slim

```slim
h1 This is a Ruby app!
```

And then edit your Rails Application layout to have nothing but a `div` with the id `app` inside it.

## Known issues

- Click events on links that don't begin with `%r{(\w+)://}` are trapped by Clearwater
  - No way to indicate a link we *don't* want the app to handle, even if it is host-relative.

## Contributing

1. Fork it ( https://github.com/jgaskins/clearwater/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
