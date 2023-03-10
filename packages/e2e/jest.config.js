const project = (displayName) => ({
  displayName,
  preset: 'ts-jest',
  setupFiles: ['dotenv/config'],
  testMatch: [`<rootDir>/test/${displayName}/**/*.test.ts`],
  transform: { '^.+\\.test.ts?$': 'ts-jest' }
});

module.exports = {
  projects: [
    { ...project('blockfrost'), globalSetup: './test/blockfrost/setup.ts' },
    project('load-testing'),
    project('local-network'),
    project('long-running'),
    project('measurement-util'),
    project('ogmios'),
    project('projection'),
    project('providers'),
    project('wallet')
  ],
  testTimeout: 1000 * 60 * 25
};
