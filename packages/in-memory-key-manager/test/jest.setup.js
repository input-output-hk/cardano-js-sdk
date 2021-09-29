/* eslint-disable unicorn/prefer-module */
/* eslint-disable @typescript-eslint/no-var-requires */

// TODO: jest environment is not happy with 'lodash-es' exports.
// I think using non-es-module 'lodash' in 'dependencies' is too heavy.
// eslint-disable-next-line unicorn/prefer-module
jest.mock('lodash-es', () => require('lodash'));

const { testTimeout } = require('./jest.config');
require('fast-check').configureGlobal({
  interruptAfterTimeLimit: testTimeout * 0.7,
  numRuns: testTimeout / 50,
  markInterruptAsFailure: true
});
