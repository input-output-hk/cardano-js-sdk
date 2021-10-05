module.exports = {
  ...require('../../test/jest.config'),
  setupFilesAfterEnv: ['../../test/jest.setup.js', './test/jest.setup.js'],
};