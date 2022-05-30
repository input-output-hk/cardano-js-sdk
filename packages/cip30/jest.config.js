module.exports = {
  ...require('../../test/jest.config'),
  setupFiles: ['jest-webextension-mock'],
  testEnvironment: 'jsdom'
};
