const path = require('path');
const VueLoaderPlugin = require('vue-loader/lib/plugin');
const webpack = require('webpack');

module.exports = {
  // entry points
  entry: {
    application: './src/javascripts/application.js',
  },
  // 出力するパスは絶対パスで書きます
  output: {
    path: `${__dirname}/../app/assets/javascripts`,
    filename: (arg) => {
      return '[name].js';
    },
  },
  // webpack4はlordersではなくなりました
  module: {
    rules: [
      // 拡張子.vueのファイルに対する設定
      {
        test: /\.vue$/,
        use: [
          {
            loader: 'vue-loader',
            options: {
              loaders: {
                js: 'babel-loader',
              },
            },
          },
          {
            loader: 'eslint-loader',
          },
        ],
      },
      // 拡張子.jsのファイルに対する設定
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'babel-loader',
          },
          {
            loader: 'eslint-loader',
          },
        ],
      },
      {
        test: /\.scss$/,
        loaders: ['style', 'css', 'sass']
      },
      {
        test: /\.css$/,
        loader: 'style-loader!css-loader'
      },
      {
        test: /\.(jpe|jpg|woff|woff2|eot|ttf|svg)(\?.*$|$)/,
        loader: 'url-loader?mimetype=application/font-woff'
      },
    ],
  },
  // デフォルトの設定値だけでは足りないことについて解決します
  resolve: {
    // モジュールを読み込むときに検索するディレクトリの設定
    modules: [path.join(__dirname, 'src'), 'node_modules'],
    alias: {
      // importのファイルパスを相対パスで書かないようにsrcのrootを設定
      '@': path.join(__dirname, 'src'),
      // 例えばmain.js内で `import Vue from 'vue';` と記述したときの`vue`が表すファイルパスを指定
      'vue$': 'vue/dist/vue.esm.js',
    },
    // 省略できる拡張子を設定
    extensions: ['.js', '.vue'],
  },
  // プラグインを列挙
  plugins: [
    new VueLoaderPlugin(),
    new webpack.ProvidePlugin({ $: 'jquery' }),
    new webpack.DefinePlugin({
      BUGSNAG_JS_API_KEY: JSON.stringify(process.env.BUGSNAG_JS_API_KEY),
    }),
  ],
};
