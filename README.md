clearwater
----------

 [![Join Chat](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/clearwater-rb/clearwater) [![Quality](http://img.shields.io/codeclimate/github/clearwater-rb/clearwater.svg?style=flat-square)](https://codeclimate.com/github/clearwater-rb/clearwater) [![Build](http://img.shields.io/travis-ci/clearwater-rb/clearwater.svg?style=flat-square)](https://travis-ci.org/clearwater-rb/clearwater) [![Downloads](http://img.shields.io/gem/dtv/clearwater.svg?style=flat-square)](https://rubygems.org/gems/clearwater) [![Issues](http://img.shields.io/github/issues/clearwater-rb/clearwater.svg?style=flat-square)](http://github.com/clearwater-rb/clearwater/issues) [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/MIT) [![Version](http://img.shields.io/gem/v/clearwater.svg?style=flat-square)](https://rubygems.org/gems/clearwater)

Clearwater is a rich front-end framework for building fast, reasonable, and easily composable browser applications in Ruby. It renders to a virtual DOM and applies the virtual DOM to the browser's actual DOM to update only what has changed on the page.

Installing
==========

Add these lines to your application's Gemfile:

``` ruby
gem 'clearwater'
gem 'opal-rails' # Only if you're using Rails
```

Using
=====

This is a minimum-viable Clearwater app:

```ruby
require 'opal'
require 'clearwater'

class HelloWorld
  include Clearwater::Component
  
  def render
    h1('Hello, world!')
  end
end

app = Clearwater::Application.new(component: HelloWorld.new)
app.call
```

Clearwater has three distinct parts:

1. The component: the presenter and template engine
1. The router (optional): the dispatcher and control
1. The application: the "Go" button

**The Component**
``` ruby
class Blog
  # All components need a set of behavior, but don't worry it's not a massive list.
  include Clearwater::Component

  # This method needs to return a virtual-DOM element using the element DSL.
  # The DSL is provided by the Clearwater::Component mixin.
  def render
    div([
      Articles.new,
      Biography.new,
    ])
  end
end
```

While we use two components in this example, you can use all of these as well:

``` ruby
# <div id="foo">
#   <h1>Heading</h1>
#   <article>hello!</article>
# </div>
def render
  div({ id: 'foo' }, [
    h1('Heading'),
    article('hello!'),
  ])
end

# <div>Hello, world!</div>
def render
  div('Hello, world!')
end

# <div>123</div>
def render
  div(123)
end

# <div></div>
def render
  div
end
```

**The Router**

``` ruby
router = Clearwater::Router.new do
  # A route with a block contains subordinate routes
  route 'blog' => Blog.new do # /blog
    route 'new_article' => NewArticle.new # /blog/new_article

    # This path contains a dynamic segment. Inside this component, you can use
    # router.params[:article_id] to return the value for this segment of the
    # URL. So for "/articles/123", router.params[:article_id] would be "123".
    route ':article_id' => ArticleReader.new # /blog/123
  end
end
```

## Using with Rails

You can also use Clearwater as part of the Rails asset pipeline. First create your Clearwater application (replace `app/assets/javascripts/application.js` with this file):

### `app/assets/javascripts/application.rb`
```ruby
require 'opal' # Not necessary if you load Opal from a CDN
require 'clearwater'

class Layout
  include Clearwater::Component

  def render
    h1('Hello, world!')
  end
end

app = Clearwater::Application.new(component: Layout.new)
app.call
```

### `app/views/layouts/application.html.erb`

```erb
<!DOCTYPE html>
<html>
  <!-- snip -->

  <body>
    <!--
      We load the JS in the body tag to ensure the element exists so we can
      render to it. Otherwise, we need to use events on the document before we
      instantiate and call the Clearwater app. And that's no fun.
    -->
    <%= javascript_include_tag 'application' %>
  </body>
</html>
```

Then you need to get Rails to render a blank page, so add these two routes:

### `config/routes.rb`
```ruby
root 'home#index'
get '*all' => 'home#index'
```

You can omit the second line if your Clearwater app doesn't use routing. It just tells Rails to let your Clearwater app handle all routes.

### `app/controllers/home_controller.rb`
```ruby
class HomeController < ApplicationController
  def index
  end
end
```

### `app/views/home/index.html.erb`
```html
<!-- This page intentionally left blank -->
```

You can use the Rails generators to generate the controller and view (`rails g controller home index`), but it won't set up the root and catch-all routes, so you'll still need to do that manually.

Once you've added those files, refresh the page. You should see "Hello, world!" in big, bold letters. Congrats! You've built your first Clearwater app on Rails!

## Using with Roda

If you're using Roda, you'll want to use the [`roda-opal_assets` gem](https://github.com/clearwater-rb/roda-opal_assets) to get an asset-pipeline-style workflow for compiling your Clearwater app into JavaScript.

## Getting Started

Use the [`clearwater-roda`](https://github.com/clearwater-rb/clearwater-roda) gem to generate a starter Clearwater app that demonstrates many components working together, routing, and even state management (via [`grand_central`](https://github.com/clearwater-rb/grand_central)).

## Experiment!

You can experiment with Clearwater using the [Clearwater Playground](https://clearwater-rb-playground.herokuapp.com). You can also explore [other saved playground experiments](https://clearwater-rb-playground.herokuapp.com/playgrounds).

Contributing
============
This project is governed by a [Code of Conduct](CODE_OF_CONDUCT.md)

  1. Fork it
  1. Branch it
  1. Hack it
  1. Save it
  1. Commit it
  1. Push it
  5. Pull-request it


License
=======

Copyright (c) 2014-2018  Jamie Gaskins

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
