const { pathsToModuleNameMapper } = require('ts-jest/utils')
const { compilerOptions } = require('./tsconfig')

module.exports = {
  setupFilesAfterEnv: ['./jest.setup.js'],
  moduleNameMapper: pathsToModuleNameMapper(compilerOptions.paths),
  preset: 'ts-jest',
  transform: {
    "^.+\\.test.ts?$": "ts-jest"
  },
  testTimeout: 120000
}
