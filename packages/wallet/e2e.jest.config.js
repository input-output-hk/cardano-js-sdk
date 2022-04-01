module.exports = {
  ...require('../../test/e2e.jest.config'),
  setupFiles: ['dotenv/config', 'jest-webextension-mock']
};
