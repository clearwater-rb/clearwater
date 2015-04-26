# Clearwater

Clearwater is a front-end framework for web applications written in Ruby. It renders to a virtual DOM and applies the virtual DOM to the browser's actual DOM to update only what has changed on the page.

## Installation

  - [![Quality](http://img.shields.io/codeclimate/github/clearwater-rb/clearwater.svg?style=flat-square)](https://codeclimate.com/github/clearwater-rb/clearwater)
  - [![Coverage](http://img.shields.io/codeclimate/coverage/github/clearwater-rb/clearwater.svg?style=flat-square)](https://codeclimate.com/github/clearwater-rb/clearwater)
  - [![Build](http://img.shields.io/travis-ci/clearwater-rb/clearwater.svg?style=flat-square)](https://travis-ci.org/clearwater-rb/clearwater)
  - [![Dependencies](http://img.shields.io/gemnasium/clearwater-rb/clearwater.svg?style=flat-square)](https://gemnasium.com/clearwater-rb/clearwater)
  - [![Downloads](http://img.shields.io/gem/dtv/clearwater.svg?style=flat-square)](https://rubygems.org/gems/clearwater)
  - [![Tags](http://img.shields.io/github/tag/clearwater-rb/clearwater.svg?style=flat-square)](http://github.com/clearwater-rb/clearwater/tags)
  - [![Releases](http://img.shields.io/github/release/clearwater-rb/clearwater.svg?style=flat-square)](http://github.com/clearwater-rb/clearwater/releases)
  - [![Issues](http://img.shields.io/github/issues/clearwater-rb/clearwater.svg?style=flat-square)](http://github.com/clearwater-rb/clearwater/issues)
  - [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/MIT)
  - [![Version](http://img.shields.io/gem/v/clearwater.svg?style=flat-square)](https://rubygems.org/gems/clearwater)

Add these lines to your application's Gemfile:

```ruby
gem 'clearwater', github: 'clearwater-rb/clearwater'
gem 'opal-browser', github: 'opal/opal-browser' # Released version is out of date
gem 'opal-rails' # For Rails apps
```

And then execute:

    $ bundle

## Usage

Clearwater targets the Rails asset pipeline, so it will work best in a Rails app. It may work fine with other server-side web frameworks, but I haven't tried it yet.

### Create your application

#### app/assets/javascripts/application.rb

```ruby
# Load Clearwater
require 'opal' # Not necessary if you load Opal from CDN
require 'clearwater'

class Layout
  include Clearwater::Component

  def render
    div({id: 'app'}, [
      header({class_name: 'main-header'}, [
        h1(nil, 'Hello, world!'),
      ]),
      outlet, # This is what renders subordinate routes
    ])
  end
end

class Articles
  include Clearwater::Component

  def render
    div({id: 'articles-container'}, [
      input({class_name: 'search-articles', onkeyup: method(:search)}),
      ul({id: 'articles-index'}, articles.map { |article|
        ArticlesListItem.new(article)
      }),
    ])
  end

  def articles
    @articles ||= MyStore.fetch_articles # TODO: implement MyStore.fetch_articles

    if @query
      @articles.select { |article| article.search(@query) }
    else
      @articles
    end
  end

  def search(event)
    @query = event.target.value
    call # Rerender the app
  end
end

class ArticlesListItem
  include Clearwater::Component

  attr_reader :article

  def initialize(article)
    @article = article
  end

  def render
    li({class_name: 'article'}, [
      # The Link component will rerender the app for the new URL on click
      Link.new({href: "/articles/#{article.id}"}, article.title),
      time({class_name: 'timestamp'}, article.timestamp.strftime('%m/%d/%Y')),
    ])
  end
end

class Article
  include Clearwater::Component

  def render
    # In addition to using HTML5 tag names as methods, you can use the `tag`
    # method with a query selector to generate a tag with those attributes.
    tag('article.selected-article', nil, [
      h1({class_name: 'article-title'}, article.title),
      time({class_name: 'article-timestamp'}, article.timestamp.strftime('%m-%d-%Y')),
      section({class_name: 'article-body'}, article.body),
    ])
  end

  def article
    # params[:article_id] is the section of the URL that contains what would be
    # the `:article_id` parameter in the router below.
    MyStore.article(params[:id])
  end
end

router = Clearwater::Router.new do
  route 'articles' => Articles.new do
    route ':article_id' => Article.new
  end
end

MyApp = Clearwater::Application.new(
  component: Layout.new,
  router: router,
  element: $document.body # This is the default target element
)

MyApp.call # Render the app
```


Contributing
============

  1. Fork it
  2. Create your feature branch (`git checkout -b my-new-feature`)
  3. Commit your changes (`git commit -am 'Add some feature'`)
  4. Push to the branch (`git push origin my-new-feature`)
  5. Create new Pull Request


Changelog
=========

  - 1.0.0: Initial release


Conduct
=======

As contributors and maintainers of this project, we pledge to respect all people who contribute through reporting issues, posting feature requests, updating documentation, submitting pull requests or patches, and other activities.

We are committed to making participation in this project a harassment-free experience for everyone, regardless of level of experience, gender, gender identity and expression, sexual orientation, disability, personal appearance, body size, race, age, or religion.

Examples of unacceptable behavior by participants include the use of sexual language or imagery, derogatory comments or personal attacks, trolling, public or private harassment, insults, or other unprofessional conduct.

Project maintainers have the right and responsibility to remove, edit, or reject comments, commits, code, wiki edits, issues, and other contributions that are not aligned to this Code of Conduct. Project maintainers who do not follow the Code of Conduct may be removed from the project team.

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by opening an issue or contacting one or more of the project maintainers.

This Code of Conduct is adapted from the [Contributor Covenant](http:contributor-covenant.org), version 1.0.0, available at [http://contributor-covenant.org/version/1/0/0/](http://contributor-covenant.org/version/1/0/0/)


License
=======

Copyright (c) 2014, 2015  Jamie Gaskins

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
