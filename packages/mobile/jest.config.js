/** @type {import('@jest/types').Config.InitialOptions} */

module.exports = {
  preset: 'react-native',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  transformIgnorePatterns: [
    'node_modules',
    'jest-runner',
  ],
  testPathIgnorePatterns: ['/node_modules/', '<rootDir>/e2e/'],
};
