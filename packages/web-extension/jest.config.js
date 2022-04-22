module.exports = {
  ...require('../../test/jest.config'),
  testEnvironment: 'jsdom',
  setupFiles: ['jest-webextension-mock'],
  globals: {
    crypto: {
      randomUUID: require('crypto').randomUUID
    }
  }
};
