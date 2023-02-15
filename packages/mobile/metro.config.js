/**
 * Metro configuration for React Native
 * https://github.com/facebook/react-native
 *
 * @format
 */

const { makeMetroConfig } = require('@rnx-kit/metro-config');
const MetroSymlinksResolver = require('@rnx-kit/metro-resolver-symlinks');

module.exports = makeMetroConfig({
  projectRoot: __dirname,
  resolver: {
    resolveRequest: MetroSymlinksResolver(),
  },
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true,
      },
    }),
  },
});
