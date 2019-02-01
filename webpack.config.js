const path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin')
const CleanWebpackPlugin = require('clean-webpack-plugin')

module.exports = {
  entry: './frontend/src/scribo.js',
  output: {
    path: __dirname + '/frontend/dist',
    filename: 'scribo.js',
    library: 'Scribo',
    libraryTarget: 'umd'
  },
  plugins: [
    // Dont compile or process the SCSS, let the user take care of that!
    new CopyWebpackPlugin(
      [
        { from: 'frontend/src/**/*.scss', to: 'scss', transformPath (targetPath, absolutePath) { return targetPath.replace('frontend/src/', ''); } },
      ], { copyUnmodified: true }
    ),
    new CleanWebpackPlugin(['frontend/dist'],  {})
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
      {
        test: /\.(|ttf|eot|svg|woff2?)(\?[\s\S]+)?$/,
        use: 'file-loader',
      },
    ]
  },
  resolve: {
    modules: [path.resolve('./node_modules'), path.resolve('./src')],
    extensions: ['.json', '.js']
  }
};
