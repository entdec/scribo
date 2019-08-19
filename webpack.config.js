const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin')
const CleanWebpackPlugin = require('clean-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin');

module.exports = {
  entry: ['./frontend/src/javascript/scribo.js', './frontend/src/style/scribo.scss'],
  output: {
    path: __dirname + '/frontend/dist',
    filename: 'scribo.js',
    library: 'Scribo',
    libraryTarget: 'umd'
  },
  plugins: [
  //   // Dont compile or process the SCSS, let the user take care of that!
  //   new CopyWebpackPlugin(
  //     [
  //       { from: 'frontend/src/style/**/*.scss', to: 'scss', transformPath (targetPath, absolutePath) { return targetPath.replace('frontend/src/style/', ''); } },
  //     ], { copyUnmodified: true }
  //   ),
    new CleanWebpackPlugin(['frontend/dist'],  {}),
    new ExtractTextPlugin({ // define where to save the file
      filename: 'scribo.css',
      allChunks: true,
    }),
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['env'],
            plugins: ["transform-class-properties"]
          }
        }
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader'],
      },
      { // sass / scss loader for webpack
        test: /\.(sass|scss)$/,
        loader: ExtractTextPlugin.extract(['css-loader', 'sass-loader'])
      },
      {
        test: /\.(|ttf|eot|svg|woff2?)(\?[\s\S]+)?$/,
        use: 'file-loader',
      },
    ]
  },
  resolve: {
    modules: [path.resolve('./node_modules'), path.resolve('./src')],
    extensions: ['.json', '.js', '.scss']
  }
};
