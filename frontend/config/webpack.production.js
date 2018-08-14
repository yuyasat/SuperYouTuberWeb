var VueLoaderPlugin = require('vue-loader/lib/plugin')
var webpack = require('webpack');
var path = require('path')
var UglifyJsPlugin = require('uglifyjs-webpack-plugin')

module.exports = {
  entry: {
    application: './src/javascripts/application.js',
    honoka: './src/javascripts/honoka.js',
    adminMovie: './src/javascripts/admin/Movie',
    adminMovieList: './src/javascripts/admin/MovieList',
    adminCategory: './src/javascripts/admin/Category',
    adminCategoryShow: './src/javascripts/admin/Category/Show',
    adminVideoArtist: './src/javascripts/admin/VideoArtist',
    adminVideoArtistShow: './src/javascripts/admin/VideoArtist/Show',
    spots: './src/javascripts/spots',
    spots_categories: './src/javascripts/spots_categories',
  },
  output: {
    path: path.resolve(__dirname, '../../app/assets/javascripts'),
    filename: '[name].js'
  },
  plugins: [
    new webpack.ProvidePlugin({ $: 'jquery', jQuery: 'jquery' }),
    new UglifyJsPlugin(),
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
