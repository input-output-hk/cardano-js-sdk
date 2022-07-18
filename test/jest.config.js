module.exports = {
  ...require('./base.jest.config'),
  resolver: `${__dirname}/resolver.js`,
  testPathIgnorePatterns: ['/e2e/', '/hardware/', '/load/']
};
