module.exports = {
  preset: 'ts-jest/presets/js-with-ts-esm',
  globals: {
    'ts-jest': {
      useESM: true,
    },
  },
  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.js$': '$1',
    // Alternatively could use this, but it takes a very long time to build without cache (~10 times longer)
    // babel instead of tsc to transform js files would probably be faster
    // transformIgnorePatterns: ["/node_modules/(?!(lodash-es)/)"],
    "lodash-es": "lodash"
  },
  coveragePathIgnorePatterns: ['\.config\.js'],
  testTimeout: process.env.CI ? 120000 : 12000,
}
