module.exports = {
  ...require('./base.jest.config'),
  testPathIgnorePatterns: ['/e2e/', '/hardware/', '/load/']
};
