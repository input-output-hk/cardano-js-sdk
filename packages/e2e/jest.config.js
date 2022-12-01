const project = (displayName) => ({
  displayName,
  preset: 'ts-jest',
  setupFiles: ['dotenv/config'],
  testMatch: [`<rootDir>/test/${displayName}/**/*.test.ts`],
  transform: { '^.+\\.test.ts?$': 'ts-jest' }
});

module.exports = {
  projects: [
    project('load-testing'),
    project('local-network'),
    project('long-running'),
    project('ogmios'),
    project('providers'),
    project('wallet')
  ],
  testTimeout: 1000 * 60 * 25
};
