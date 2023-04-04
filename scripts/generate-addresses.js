// Usage: node scripts/generate-addresses.js 10000 1
// Where 10000 is # of addresses, and 1 is NetworkId (mainnet)

/* eslint-disable import/no-extraneous-dependencies */
const { Cardano } = require('@cardano-sdk/core');
const { util, InMemoryKeyAgent } = require('@cardano-sdk/key-management');
const Crypto = require('@cardano-sdk/crypto');
const CML = require('@emurgo/cardano-serialization-lib-nodejs');
const fs = require('fs');

const mnemonicWords = util.generateMnemonicWords();
const numAddresses = Number.parseInt(process.argv[2]);
const networkId = Number.parseInt(process.argv[3]);
const passphrase = 'passphrase';

(async () => {
  const keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      accountIndex: 0,
      chainId: networkId === 0 ? Cardano.ChainIds.Preprod : Cardano.ChainIds.Mainnet,
      getPassphrase: async () => passphrase,
      mnemonic2ndFactorPassphrase: passphrase,
      mnemonicWords
    },
    {
      bip32Ed25519: new Crypto.CmlBip32Ed25519(CML),
      inputResolver: {},
      logger: console
    }
  );

  const addresses = [];
  let index = 0;
  while (addresses.length < numAddresses) {
    const { address, rewardAccount } = await keyAgent.deriveAddress({ index: index++, type: 0 });
    addresses.push({
      address,
      stake_address: rewardAccount,
      tx_count: 0
    });
  }
  fs.writeFileSync('addreses.json', JSON.stringify(addresses));
})();
