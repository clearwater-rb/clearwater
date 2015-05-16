# Clearwater

Clearwater is a front-end framework for web applications written in Ruby. It renders to a virtual DOM and applies the virtual DOM to the browser's actual DOM to update only what has changed on the page.

## Installation

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
require 'clearwater/application'
require 'clearwater/component'

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

## Contributing

1. Fork it ( https://github.com/jgaskins/clearwater/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am "Add some feature"`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
