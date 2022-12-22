// eslint-disable-next-line import/no-extraneous-dependencies
const { DefinePlugin, NormalModuleReplacementPlugin, ProvidePlugin, IgnorePlugin } = require('webpack');
const path = require('path');

const distDir = path.join(__dirname, 'dist');

// this is insecure, as it builds in your system's env variables. use webpack-dotenv or similar instead.
require('dotenv').config({ path: path.join(__dirname, '../../', '.env') });

module.exports = {
  baseConfig: {
    devtool: 'inline-source-map',
    mode: 'development',
    module: {
      // configuration regarding modules
      rules: [
        {
          exclude: /node_modules/,
          resolve: {
            fullySpecified: false
          },
          test: /\.(js|ts)$/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                presets: ['@babel/preset-env', '@babel/preset-typescript']
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
      new NormalModuleReplacementPlugin(/@cardano-sdk/, (resource) => {
        const base = resource.context.replace(path.join(__dirname, '../../../'));
        const level = base.match(/\//g).length + 2;
        const prefix = Array.from({ length: level }).join('../');
        // eslint-disable-next-line prefer-template
        const newPath = resource.request.replace(/@cardano-sdk\//, prefix) + '/src';
        resource.request = newPath;
      }),
      new DefinePlugin({
        'process.env': JSON.stringify(process.env)
      }),
      new NormalModuleReplacementPlugin(
        /@dcspark\/cardano-multiplatform-lib-nodejs/,
        '@dcspark/cardano-multiplatform-lib-browser'
      ),
      new NormalModuleReplacementPlugin(/blake2b$/, 'blake2b-no-wasm'),
      new NormalModuleReplacementPlugin(
        /@emurgo\/cardano-message-signing-nodejs/,
        '@emurgo/cardano-message-signing-asmjs'
      ),
      new ProvidePlugin({
        Buffer: ['buffer', 'Buffer'],
        process: 'process/browser'
      }),
      new IgnorePlugin({
        contextRegExp: /bip39\/src\/wordlists$/,
        resourceRegExp: /^\.\/(?!english)/
      })
    ],
    resolve: {
      alias: {
        // imported by faucet provider in e2e/src, not used in web-extension
        'cardano-wallet-js': false
      },
      extensions: ['.ts', '.js'],
      fallback: {
        buffer: require.resolve('buffer/'),
        events: require.resolve('events/'),
        fs: false,
        'get-port-please': false,
        http: false,
        net: false,
        os: false,
        path: false,
        perf_hooks: false,
        stream: require.resolve('readable-stream'),
        util: require.resolve('util/')
      }
    },
    watchOptions: {
      ignored: ['**/node_modules', distDir]
    }
  },
  distDir
};
