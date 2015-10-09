clearwater
----------

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

Clearwater is a rich front-end framework for building fast, reasonable, and easily composable browser applications in Ruby. It renders to a virtual DOM and applies the virtual DOM to the browser's actual DOM to update only what has changed on the page.

Installing
==========

If you're using this as a standalone application then just install via:

    $ gem install clearwater

If you're using rails then add these lines to your application's Gemfile:

``` ruby
gem 'clearwater'
gem 'opal-rails' # Only needed for Rails apps
```


Using
=====

Clearwater has three distinct parts:

1. The component: the presenter and template engine
1. The router: the dispatcher and control
1. The application: the "Go" button

**The Component**
``` ruby
class Blog
  # All components need a set of behavior, but don't worry it's not a massive list.
  include Clearwater::Component

  # This method needs to return a virtual-DOM element using the element DSL.
  def render
    main({ id: 'content' }, [Articles.new, Biography.new])
  end
end
```

While we use two components in this example, you can use all of these as well:

``` ruby
# Render <main><h1>Heading</h1><article>hello!</article></main>
def render
  main(properties, [h1('Heading'), article('hello!')])
end

# Render <main>Hello, world!</main>
def render
  main(properties, 'Hello, world!')
end

# Render <main>123</main>
def render
  main(properties, 123)
end

# Render <main></main>
def render
  main(properties, nil)
end
```

**The Router**

``` ruby
router = Clearwater::Router.new do
  route 'blog' => Blog.new do
    route 'new_article' => NewArticle.new
    route ':article_id' => ArticleReader.new
  end
end
```

You can also use Clearwater as part of the Rails asset pipeline. First create your application:

``` ruby
# file: app/assets/javascripts/application.rb
require 'opal' # Not necessary if you load Opal from a CDN
require 'clearwater'

class Layout
  include Clearwater::Component

  def render
    div({ id: 'app' }, [
      header({ class_name: 'main-header' }, [
        h1('Hello, world!'),
      ]),
      outlet, # This is what renders subordinate routes
    ])
  end
end

class Articles
  include Clearwater::Component

  def render
    div({ id: 'articles-container '}, [
      input({ class_name: 'search-articles', onkeyup: method(:search) }),
      ul({ id: 'articles-index' }, articles.map { |article|
        ArticlesListItem.new(article)
      }),
      outlet, # This is what renders subordinate routes (e.g. Article)
    ])
  end

  def articles
    @articles ||= MyStore.fetch_articles

    if @query
      @articles.select { |article| article.match?(@query) }
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
    # Note the "key" key in this hash. This is a hint to the virtual DOM that
    # if this node is moved around, it can still reuse the same element.
    li({ key: article.id, class_name: 'article' }, [
      # The Link component will rerender the app for the new URL on click
      Link.new({ href: "/articles/#{article.id}" }, article.title),
      time({ class_name: 'timestamp' }, article.timestamp.strftime('%m/%d/%Y')),
    ])
  end
end

class Article
  include Clearwater::Component

  def render
    # In addition to using HTML5 tag names as methods, you can use the `tag`
    # method with a query selector to generate a tag with those attributes.
    tag('article.selected-article', nil, [
      h1({ class_name: 'article-title' }, article.title),
      time({ class_name: 'article-timestamp' }, article.timestamp.strftime('%m-%d-%Y')),
      section({ class_name: 'article-body' }, article.body),
    ])
  end

  def article
    # params[:article_id] is the section of the URL that contains what would be
    # the `:article_id` parameter in the router below.
    MyStore.article(params[:article_id])
  end

  def match? query
    query.split.all? { |token|
      title.include?(token) || body.include?(token)
    }
  end
end

module MyStore
  extend self
  DB = 5.times.map do |n|
    OpenStruct.new(id: n, timestamp: Time.new, title: "Random thoughts n.#{n}", body: 'Some deep stuff')
  end

  def fetch_articles
    DB
  end

  def article(id)
    id = id.to_i
    DB.find {|a| a.id == id}
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

MyApp.call # Render the app.
```


Contributing
============

  1. Fork it
  1. Branch it
  1. Hack it
  1. Save it
  1. Commit it
  1. Push it
  5. Pull-request it


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

Copyright (c) 2014-2015  Jamie Gaskins

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
