module.exports = {
  preset: 'ts-jest',
  moduleNameMapper: {
    "^lodash-es$": "lodash"
  },
  transform: {
    "^.+\\.test.ts?$": "ts-jest"
  },
  coveragePathIgnorePatterns: ['\.config\.js'],
  testTimeout: process.env.CI ? 120000 : 12000,
}
