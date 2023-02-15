/** @type {import('@jest/types').Config.InitialOptions} */

module.exports = {
  rootDir: '..',
  testMatch: ['<rootDir>/e2e/**/*.test.ts'],
  testTimeout: 120_000,
  maxWorkers: 1,
  globalSetup: 'detox/runners/jest/globalSetup',
  globalTeardown: 'detox/runners/jest/globalTeardown',
  reporters: [
    'detox/runners/jest/reporter',
    ['jest-allure2-reporter', { resultsDir: 'e2e/allure-results' }],
  ],
  testEnvironment: 'detox/runners/jest/testEnvironment',
  verbose: true,
};
