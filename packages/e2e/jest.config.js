/* eslint-disable sonarjs/no-duplicate-string */
module.exports = {
  projects: [
    {
      displayName: 'wallet',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: ['<rootDir>/test/wallet/**/*.test.ts'],
      transform: {
        '^.+\\.test.ts?$': 'ts-jest'
      }
    },
    {
      displayName: 'local-network',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: ['<rootDir>/test/local-network/**/*.test.ts'],
      transform: {
        '^.+\\.test.ts?$': 'ts-jest'
      }
    },
    {
      displayName: 'load-testing',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: ['<rootDir>/test/load-testing/**/*.test.ts'],
      transform: {
        '^.+\\.test.ts?$': 'ts-jest'
      }
    },
    {
      displayName: 'ogmios',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: ['<rootDir>/test/ogmios/**/*.test.ts'],
      transform: {
        '^.+\\.test.ts?$': 'ts-jest'
      }
    },
    {
      displayName: 'long-running',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: ['<rootDir>/test/long-running/**/*.test.ts'],
      transform: {
        '^.+\\.test.ts?$': 'ts-jest'
      }
    },
    {
      displayName: 'providers',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: ['<rootDir>/test/providers/**/*.test.ts'],
      transform: {
        '^.+\\.test.ts?$': 'ts-jest'
      }
    }
  ],
  testTimeout: 1000 * 60 * 25
};
