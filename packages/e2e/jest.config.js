const commonProjectProps = {
  preset: 'ts-jest',
  setupFiles: ['dotenv/config'],
  transform: { '^.+\\.test.ts?$': 'ts-jest' }
};

const project = (displayName) => ({
  displayName,
  testMatch: [`<rootDir>/test/${displayName}/**/*.test.ts`],
  ...commonProjectProps
});

// jest tests suitable to run in an environment with real ADA (not tADA)
const realAdaTestFileNames = [
  'delegation',
  'metadata',
  'mint',
  'multisignature',
  'nft',
  'pouchDbWalletStores',
  'txChainHistory',
  'txChaining',
  'unspendableUtxos'
];

// TODO: remove this and unify wallet and wallet-conway back into a single `wallet`
const conwayEraTestFileNames = ['conwayTransactions'];

module.exports = {
  projects: [
    { ...project('blockfrost'), globalSetup: './test/blockfrost/setup.ts' },
    project('local-network'),
    project('long-running'),
    project('ogmios'),
    project('pg-boss'),
    project('projection'),
    project('providers'),
    {
      ...project('wallet'),
      // TODO: remove this once DbSync has a unified version and we run all tests on conway era
      testPathIgnorePatterns: [`<rootDir>/test/wallet/PersonalWallet/(${conwayEraTestFileNames.join('|')}).test.ts`]
    },
    {
      ...commonProjectProps,
      displayName: 'wallet-conway',
      testMatch: [`<rootDir>/test/wallet/PersonalWallet/(${conwayEraTestFileNames.join('|')}).test.ts`]
    },
    {
      ...commonProjectProps,
      displayName: 'wallet-real-ada',
      testMatch: [`<rootDir>/test/wallet/PersonalWallet/(${realAdaTestFileNames.join('|')}).test.ts`]
    },
    {
      ...commonProjectProps,
      displayName: 'utils',
      testMatch: ['<rootDir>/test/measurement-util/*.test.ts', '<rootDir>/test/util.test.ts']
    }
  ],
  testTimeout: 1000 * 60 * 25
};
