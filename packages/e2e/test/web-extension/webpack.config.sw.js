/* eslint-disable import/no-extraneous-dependencies */
const { baseConfig } = require('./webpack.config.base');
const { merge } = require('webpack-merge');
const path = require('path');

module.exports = merge(baseConfig, {
  entry: {
    background: path.join(__dirname, 'extension/background/index.ts')
  },
  module: {
    // configuration regarding modules
    rules: [
      {
        test: /\.wasm$/,
        type: 'javascript/auto',
        use: {
          loader: 'webassembly-loader-sw',
          options: {
            export: 'instance',
            importObjectProps:
              // eslint-disable-next-line max-len
              '\'./cardano_multiplatform_lib_bg.js\': __webpack_require__("../../node_modules/@dcspark/cardano-multiplatform-lib-browser/cardano_multiplatform_lib_bg.js")'
          }
        }
      }
    ]
  }
});
