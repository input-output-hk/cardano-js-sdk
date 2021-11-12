module.exports = {
  ...require('./base.jest.config'),
  testRegex: '(/e2e/.*(test|spec))\\.[jt]sx?$',
  setupFiles: ['dotenv/config'],
  testTimeout: 600_000
};
