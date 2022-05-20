const path = require('path');
const nodeExternals = require('webpack-node-externals');
const webpack = require('webpack');

module.exports = {
  entry: {
    cli: './src/cli.ts'
  },
  externals: [
    nodeExternals({
      additionalModuleDirs: [path.join(__dirname, '../../node_modules')],
      allowlist: ['@cardano-sdk/core', '@cardano-sdk/ogmios', '@cardano-sdk/rabbitmq', 'lodash-es']
    })
  ],
  mode: 'production',
  module: {
    rules: [
      {
        exclude: /node_modules/,
        test: /\.ts$/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-typescript']
            }
          }
        ]
      }
    ]
  },
  output: {
    filename: '[name].js',
    path: path.join(__dirname, 'dist')
  },
  plugins: [
    new webpack.NormalModuleReplacementPlugin(/@cardano-sdk/, (resource) => {
      const base = resource.context.replace(path.join(__dirname, '../'));
      const level = base.match(/\//g).length + 2;
      const prefix = Array.from({ length: level }).join('../');
      // eslint-disable-next-line prefer-template
      const newPath = resource.request.replace(/@cardano-sdk\//, prefix) + '/src';
      resource.request = newPath;
    })
  ],
  resolve: {
    extensions: ['.ts', '.js']
  },
  target: 'node'
};
