const CopyPlugin = require('copy-webpack-plugin');
const path = require('path');

const distDir = path.join(__dirname, 'dist');

module.exports = {
  devtool: 'cheap-module-source-map',
  entry: {
    contentScript: path.join(__dirname, 'extension/contentScript.ts')
  },
  mode: 'development',
  module: {
    // configuration regarding modules
    rules: [
      {
        exclude: /node_modules/,
        test: /\.ts$/,
        use: [
          {
            loader: 'ts-loader',
            options: {
              compilerOptions: {
                outDir: distDir
              }
            }
          }
        ]
      }
    ]
  },
  output: {
    filename: '[name].js',
    path: distDir
  },
  plugins: [
    new CopyPlugin({
      patterns: [{ from: path.join(__dirname, 'extension/manifest.json'), to: distDir }]
    })
  ],
  resolve: {
    extensions: ['.ts']
  }
};
