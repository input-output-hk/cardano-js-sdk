/* eslint-disable import/no-extraneous-dependencies */
const { baseConfig, distDir } = require('./webpack.config.base');
const { merge } = require('webpack-merge');
const path = require('path');
const CopyPlugin = require('copy-webpack-plugin');

module.exports = merge(baseConfig, {
  entry: {
    contentScript: path.join(__dirname, 'extension/contentScript.ts'),
    dapp: path.join(__dirname, 'dapp-sdk/dapp-sdk.ts'),
    injectedScript: path.join(__dirname, 'extension/injectedScript.ts'),
    ui: path.join(__dirname, 'extension/ui-entry.ts')
  },
  experiments: {
    syncWebAssembly: true
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: path.join(__dirname, 'extension/manifest.json'), to: distDir },
        { from: path.join(__dirname, 'extension/ui.html'), to: distDir },
        { from: path.join(__dirname, 'dapp-sdk/dapp-sdk.html'), to: distDir },
        { from: path.join(__dirname, 'dapp-sdk/dapp.css'), to: distDir }
      ]
    })
  ]
});
