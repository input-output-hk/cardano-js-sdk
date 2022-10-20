module.exports = {
  ...require('../../test/jest.config'),
  globalSetup: './test/jest-setup/jest-setup.ts',
  globalTeardown: './test/jest-setup/jest-teardown.ts',
  setupFilesAfterEnv: ['./test/jest-setup/matchers.ts']
};
