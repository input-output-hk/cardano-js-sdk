module.exports = {
  setupFilesAfterEnv: ['./test/jest.setup.js'],
  preset: 'ts-jest',
  transform: {
    "^.+\\.test.ts?$": "ts-jest"
  },
  testTimeout: 120000
}
