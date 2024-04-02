// eslint-disable-next-line import/no-extraneous-dependencies
const { DefinePlugin, NormalModuleReplacementPlugin, ProvidePlugin, IgnorePlugin } = require('webpack');

const path = require('path');

const distDir = path.join(__dirname, 'dist');

// this is insecure, as it builds in your system's env variables. use webpack-dotenv or similar instead.
require('dotenv').config({ path: path.join(__dirname, '../../', '.env') });

module.exports = {
  baseConfig: {
    devtool: 'source-map',
    ignoreWarnings: [/Failed to parse source map/],
    mode: 'development',
    module: {
      // configuration regarding modules
      rules: [
        {
          test: /\.css$/i,
          use: ['style-loader', 'css-loader']
        },
        {
          enforce: 'pre',
          test: /\.js$/,
          use: ['source-map-loader']
        },
        {
          exclude: /node_modules/,
          resolve: {
            fullySpecified: false
          },
          test: /\.(js|ts|tsx)$/,
          use: [
            {
              loader: 'babel-loader',
              options: {
                plugins: [
                  '@babel/transform-runtime',
                  ['@babel/transform-react-jsx', { importSource: 'preact', runtime: 'automatic' }]
                ],
                presets: ['@babel/preset-react', '@babel/preset-env', '@babel/preset-typescript']
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
        react: 'preact/compat',
        'react-dom': 'preact/compat'
      },
      extensions: ['.ts', '.js', '.tsx'],
      fallback: {
        buffer: require.resolve('buffer/'),
        crypto: require.resolve('crypto-browserify'),
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
    stats: 'errors-only',
    watchOptions: {
      ignored: ['**/node_modules', distDir]
    }
  },
  distDir
};
