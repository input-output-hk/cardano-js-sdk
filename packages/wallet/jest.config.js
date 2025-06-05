module.exports = {
  ...require('../../test/jest.config'),
  setupFiles: ['jest-webextension-mock', './jest.setup.js']
};
