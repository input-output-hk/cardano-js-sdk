const schemaConfig = require('./schema.config');

module.exports = {
  devtool: 'eval-cheap-module-source-map',
  entry: './src/Schema/index.ts',
  // everything not starting with "." (relative)
  externals: [/^(?!\.)/],
  mode: 'development',
  module: {
    // configuration regarding modules
    rules: [
      {
        exclude: /node_modules/,
        test: /\.ts$/,
        use: [
          { loader: 'ts-loader', options: { compilerOptions: { noUnusedLocals: false } } },
          { loader: 'ifdef-loader', options: schemaConfig }
        ]
      }
    ]
  },
  output: {
    filename: 'index.js',
    library: {
      type: 'commonjs'
    },
    path: `${__dirname}/dist/SchemaGen`
  },
  resolve: {
    extensions: ['.ts']
  },
  target: 'node14.17'
};
