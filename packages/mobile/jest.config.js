/** @type {import('@jest/types').Config.InitialOptions} */

const untranspiledModulePatterns = ['react-native', '@react-native*'];

module.exports = {
  preset: 'react-native',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  transformIgnorePatterns: [
    `node_modules/.pnpm/(?!${untranspiledModulePatterns.join('|')})`,
  ],
  testPathIgnorePatterns: ['/node_modules/', '<rootDir>/e2e/'],
};
