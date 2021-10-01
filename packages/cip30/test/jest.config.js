const { pathsToModuleNameMapper } = require('ts-jest/utils')
const { compilerOptions } = require('./tsconfig')

module.exports = {
  moduleNameMapper: pathsToModuleNameMapper(compilerOptions.paths),
  testEnvironment: 'jsdom',
  preset: 'ts-jest',
  transform: {
    "^.+\\.test.ts?$": "ts-jest"
  },
  testTimeout: 120000
}
