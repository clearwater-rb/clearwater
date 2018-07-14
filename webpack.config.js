module.exports = {
  entry: './index.js',
  output: {
    path: './opal/clearwater/virtual_dom/js',
    filename: 'virtual_dom.js',
    libraryTarget: 'umd',
    library: 'virtualDom',
  },
  target: 'web',
  loaders: [
    {
      test: /.js$/,
      exclude: /(node_modules|bower_components)/,
      loader: 'babel-loader',
      query: {
        presets: ['es2015'],
      },
    },
  ],
};
