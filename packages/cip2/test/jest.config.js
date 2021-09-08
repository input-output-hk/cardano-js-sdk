const { pathsToModuleNameMapper } = require('ts-jest/utils')
const { compilerOptions } = require('./tsconfig')

module.exports = {
  moduleNameMapper: pathsToModuleNameMapper(compilerOptions.paths),
  setupFilesAfterEnv: ['./jest.setup.js'],
  preset: 'ts-jest',
  transform: {
    "^.+\\.test.ts?$": "ts-jest"
  },
  testTimeout: 120000
}
