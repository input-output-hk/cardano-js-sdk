const CopyPlugin = require('copy-webpack-plugin');
const { DefinePlugin, NormalModuleReplacementPlugin, ProvidePlugin, IgnorePlugin } = require('webpack');
const path = require('path');

const distDir = path.join(__dirname, 'dist');

// this is insecure, as it builds in your system's env variables. use webpack-dotenv or similar instead.
require('dotenv').config({ path: path.join(__dirname, '.env') });

module.exports = {
    devtool: 'inline-source-map',
    entry: {
        background: path.join(__dirname, 'extension/background/index.ts'),
        contentScript: path.join(__dirname, 'extension/contentScript.ts'),
        injectedScript: path.join(__dirname, 'extension/injectedScript.ts'),
        ui: path.join(__dirname, 'extension/ui.ts')
    },
    experiments: {
        syncWebAssembly: true
    },
    mode: 'development',
    module: {
        // configuration regarding modules
        rules: [{
            exclude: /node_modules/,
            resolve: {
                fullySpecified: false
            },
            test: /\.(js|ts)$/,
            use: [{
                loader: 'babel-loader',
                options: {
                    presets: ['@babel/preset-env', '@babel/preset-typescript']
                }
            }]
        }]
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
            /@emurgo\/cardano-serialization-lib-nodejs/,
            '@emurgo/cardano-serialization-lib-asmjs'
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
        }),
        new CopyPlugin({
            patterns: [
                { from: path.join(__dirname, 'extension/manifest.json'), to: distDir },
                { from: path.join(__dirname, 'extension/ui.html'), to: distDir }
            ]
        })
    ],
    resolve: {
        extensions: ['.ts', '.js'],
        fallback: {
            buffer: require.resolve('buffer/'),
            events: require.resolve('events/'),
            fs: false,
            os: false,
            path: false,
            stream: require.resolve('readable-stream'),
            util: require.resolve('util/')
        }
    },
    watchOptions: {
        ignored: ['**/node_modules', distDir]
    }
};