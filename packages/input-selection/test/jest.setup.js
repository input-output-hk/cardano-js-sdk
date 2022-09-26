/* eslint-disable unicorn/prefer-module */
const { testTimeout } = require('../jest.config');
require('fast-check').configureGlobal({
  interruptAfterTimeLimit: testTimeout * 0.7,
  markInterruptAsFailure: true,
  numRuns: testTimeout / 50
});
