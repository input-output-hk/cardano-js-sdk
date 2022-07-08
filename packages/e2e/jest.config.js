/* eslint-disable sonarjs/no-duplicate-string */
module.exports = {
  projects: [
    {
      displayName: 'blockfrost',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: ['<rootDir>/test/blockfrost/*.test.ts'],
      transform: {
        '^.+\\.tsx?$': 'ts-jest'
      }
    },
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
      displayName: 'faucet',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: ['<rootDir>/test/faucet/**/*.test.ts'],
      transform: {
        '^.+\\.test.ts?$': 'ts-jest'
      }
    },
    {
      displayName: 'cardano-services',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: ['<rootDir>/test/cardano-services/**/*.test.ts'],
      transform: {
        '^.+\\.test.ts?$': 'ts-jest'
      }
    }
  ],
  testTimeout: 120_000_000
};
