const common = {
  ...require('../../test/jest.config'),
  globalSetup: './test/jest-setup/jest-setup.ts',
  globalTeardown: './test/jest-setup/jest-teardown.ts',
  setupFilesAfterEnv: ['./test/jest-setup/matchers.ts']
};

module.exports = {
  ...common,
  projects: [
    { ...common, displayName: 'cli', testMatch: ['<rootDir>/test/cli.test.ts'] },
    { ...common, displayName: 'unit', testPathIgnorePatterns: ['cli.test'] }
  ]
};
