module.exports = {
  ...require('../../test/base.jest.config'),
  setupFiles: ['jest-webextension-mock'],
  testRegex: '(/hardware/.*(test|spec))\\.[jt]sx?$',
  testTimeout: 600_000
}