/* eslint-disable import/no-extraneous-dependencies */
const config = require('./webpack.config.base');
const { merge } = require('webpack-merge');
const HtmlWebpackPlugin = require('html-webpack-plugin');

const path = require('path');

module.exports = merge(config.baseConfig, {
  devServer: {
    compress: true,
    port: 9000,
    static: {
      directory: path.join(__dirname, 'dist')
    }
  },
  entry: './src/index.tsx',
  experiments: {
    syncWebAssembly: true
  },

  plugins: [new HtmlWebpackPlugin()]
});
