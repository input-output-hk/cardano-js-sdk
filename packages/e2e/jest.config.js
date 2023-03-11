const project = (displayName) => ({
  displayName,
  preset: 'ts-jest',
  setupFiles: ['dotenv/config'],
  testMatch: [`<rootDir>/test/${displayName}/**/*.test.ts`],
  transform: { '^.+\\.test.ts?$': 'ts-jest' }
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
    project('measurement-util'),
    project('ogmios'),
    project('projection'),
    project('providers'),
    project('wallet'),
    {
      displayName: 'wallet-real-ada',
      preset: 'ts-jest',
      setupFiles: ['dotenv/config'],
      testMatch: [`<rootDir>/test/wallet/SingleAddressWallet/(${realAdaTestFileNames.join('|')}).test.ts`],
      transform: { '^.+\\.test.ts?$': 'ts-jest' }
    }
  ],
  testTimeout: 1000 * 60 * 25
};
