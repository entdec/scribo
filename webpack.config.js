const path = require('path');
const CleanWebpackPlugin = require('clean-webpack-plugin')
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  entry: ['./frontend/src/javascript/scribo.js','./frontend/src/style/scribo.scss'],
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
    // new ExtractTextPlugin({ // define where to save the file
    //   filename: 'scribo.css',
    //   allChunks: true,
    // }),
    new MiniCssExtractPlugin({
      filename: 'scribo.css'
    }),
  ],
  module: {
    rules: [
      {
        test: /\.(png|jp(e*)g|svg)$/,
        use: [{
          loader: 'url-loader',
          options: {
            limit: 8000, // Convert images < 8kb to base64 strings
            // name: 'images/[hash]-[name].[ext]'
          }
        }]
      },
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
        test: /\.(sass|scss|css)$/,
        use: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          'css-loader?sourceMap=false',
          'sass-loader?sourceMap=false'
        ]
      }
    ]
  },
  resolve: {
    modules: [path.resolve('./node_modules'), path.resolve('./src')],
    extensions: ['.json', '.js', '.scss']
  }
};
