module.exports = {
  coveragePathIgnorePatterns: ['.config.js'],
  preset: 'ts-jest',
  resolver: 'ts-jest-resolver',
  testTimeout: process.env.CI ? 120_000 : 12_000,
  transform: {
    '^.+\\.test.ts?$': 'ts-jest'
  }
};
