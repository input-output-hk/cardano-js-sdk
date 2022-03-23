module.exports = {
  ...require('../../test/base.jest.config'),
  testRegex: '(/hardware/.*(test|spec))\\.[jt]sx?$',
  testTimeout: 600_000
}