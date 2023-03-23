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

module.exports = {
  projects: [
    { ...project('blockfrost'), globalSetup: './test/blockfrost/setup.ts' },
    project('load-testing'),
    project('local-network'),
    project('long-running'),
    project('ogmios'),
    project('projection'),
    project('providers'),
    project('wallet'),
    {
      ...commonProjectProps,
      displayName: 'wallet-real-ada',
      testMatch: [`<rootDir>/test/wallet/SingleAddressWallet/(${realAdaTestFileNames.join('|')}).test.ts`]
    },
    {
      ...commonProjectProps,
      displayName: 'utils',
      testMatch: ['<rootDir>/test/measurement-util/*.test.ts', '<rootDir>/test/util.test.ts']
    }
  ],
  testTimeout: 1000 * 60 * 25
};
