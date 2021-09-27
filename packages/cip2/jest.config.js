module.exports = {
  setupFilesAfterEnv: ['./test/jest.setup.js'],
  preset: 'ts-jest',
  transform: {
    "^.+\\.test.ts?$": "ts-jest"
  },
  testTimeout: process.env.CI ? 120000 : 12000,
}
