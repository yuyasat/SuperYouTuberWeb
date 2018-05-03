var webpack = require('webpack');
var path = require('path')
var UglifyJsPlugin = require('uglifyjs-webpack-plugin')

module.exports = {
  entry: {
    application: './src/javascripts/application.js',
    honoka: './src/javascripts/honoka.js',
    adminMovie: './src/javascripts/admin/Movie',
    adminMovieList: './src/javascripts/admin/MovieList',
    adminCategoryShow: './src/javascripts/admin/Category/Show',
    adminVideoArtist: './src/javascripts/admin/VideoArtist',
    spots: './src/javascripts/spots',
  },
  output: {
    path: path.resolve(__dirname, '../../app/assets/javascripts'),
    filename: '[name].js'
  },
  plugins: [
    new webpack.ProvidePlugin({ $: 'jquery', jQuery: 'jquery' }),
    new UglifyJsPlugin()
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
        use: ['vue-loader', 'eslint-loader']
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
