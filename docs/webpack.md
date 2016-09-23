# Usage with webpack

[Webpack](https://webpack.github.io/)
is a popular module bundler that can package your clearwater application for the browser.

Webpack is usually used with javascript projects but with [opal-webpack](https://github.com/cj/opal-webpack/)
it can also be used with ruby files.

## Installation

Webpack uses the npm ecosystem and can be installed with:

````
$ npm install -g webpack opal-webpack
```

## Configuring

Create a `webpack.config.js` in the root of your project.

```js
module.exports = {
  devtool: 'source-map',           // optional
  entry: './app/application.rb',
  output: {
    filename: './build/bundle.js'
  },
  module: {
    loaders: [
      {
        test: /\.rb?$/,
        loader: "opal-webpack"
      }
    ]
  },
  externals: [
    { opal: 'Opal' }
  ],
  opal: {
    cacheDirectory: './tmp/cache', // optional
    externalOpal: true             // optional
  }
};
```

More information [here](https://webpack.github.io/docs/configuration.html).

## Building

`opal-webpack` needs to find the correct gems to use with your project so the
simplest solution is to run it through `rake`.

Rakefile
```ruby
require 'bundler/setup'

require 'opal'

Bundler.require

desc "Start webpack"
task :webpack do
  exec({"OPAL_LOAD_PATH" => Opal.paths.join(":")}, "webpack")
end

desc "Start webpack and rebuild when changes are made"
task :webpack_watch do
  exec({"OPAL_LOAD_PATH" => Opal.paths.join(":")}, "webpack -w")
end
```

Gemfile
```ruby
source 'https://rubygems.org'

gem 'rake'
gem 'opal'
gem 'clearwater', '1.0.0.rc4'
```

More information [here](https://github.com/cj/opal-webpack#load-path)

## Using the bundle

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8"/>
    <script src="http://cdn.opalrb.org/opal/0.10.1/opal.js"></script>
  </head>
  <body>
    <script src="build/bundle.js"></script>
  </body>
</html>
```

## Further reading

- [Webpack](https://webpack.github.io)
- [opal-webpack](https://github.com/cj/opal-webpack)
- [Opal](https://opalrb.org)

## Caveats

`opal-webpack` has some issues with `javascript` files required from ruby. A simple workaround for clearwater
is to put the following in your entry file.

```ruby
`global.virtualDom = require('virtual-dom');`

require 'clearwater'
```

This was tested with `Opal` 0.10.1, `Clearwater` 1.0.0.rc4, `webpack` 1.13.2 and `opal-webpack` 1.0.9.