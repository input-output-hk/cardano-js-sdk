module.exports = {
  ...require('../../test/jest.config'),
  testEnvironment: 'jsdom',
  setupFiles: ['jest-webextension-mock']
};
