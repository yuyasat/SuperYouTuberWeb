var VueLoaderPlugin = require('vue-loader/lib/plugin')
var webpack = require('webpack');
var path = require('path')

module.exports = {
  devtool: 'inline-source-map',
  entry: {
    application: './src/javascripts/application.js',
  },
  output: {
    path: path.resolve(__dirname, '../../app/assets/javascripts'),
    filename: '[name].js'
  },
  plugins: [
    new webpack.ProvidePlugin({ $: 'jquery', jQuery: 'jquery' }),
    new VueLoaderPlugin(),
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules\/(?!(dom7|ssr-window|swiper)\/).*/,
        use: ['babel-loader']
      },
      {
        test: /\.vue$/,
        use: ['vue-loader']
      },
      {
        test: /\.scss$/,
        loaders: ['style', 'css', 'sass']
      },
      { test: /\.css$/, loader: 'style-loader!css-loader' },
      {
        test: /\.(jpe|jpg|woff|woff2|eot|ttf|svg)(\?.*$|$)/,
        loader: 'url-loader?mimetype=application/font-woff'
      }
    ]
  },
  resolve: {
    alias: {
      'vue': 'vue/dist/vue.common.js',
    },
  }
}
