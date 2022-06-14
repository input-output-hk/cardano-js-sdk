module.exports = {
  ...require('../../test/base.jest.config'),
  // setupFiles: ['dotenv/config', 'jest-webextension-mock'],
  setupFiles: ['dotenv/config'],
  testRegex: '(/load/.*(test|spec))\\.[jt]sx?$',
  testTimeout: 600_000
};
