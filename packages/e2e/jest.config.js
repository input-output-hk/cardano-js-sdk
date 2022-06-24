module.exports = {
  coveragePathIgnorePatterns: ['.config.js'],
  preset: 'ts-jest',
  setupFiles: ['dotenv/config'],
  testTimeout: 1_120_000,
  transform: {
    '^.+\\.test.ts?$': 'ts-jest'
  }
};
