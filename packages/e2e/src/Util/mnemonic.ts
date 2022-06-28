/* eslint-disable no-console */
import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '@cardano-sdk/wallet';

/**
 * Generates a new set of Mnemonic words and prints them to the console.
 */
(async () => {
  let mnemonic = '';
  const mnemonicArray = KeyManagement.util.generateMnemonicWords();
  for (const word of mnemonicArray) mnemonic += `${word} `;

  const keyAgentFromMnemonic = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
    getPassword: async () => Buffer.from(''),
    mnemonicWords: mnemonicArray,
    networkId: Cardano.NetworkId.testnet
  });

  const derivedAddress = await keyAgentFromMnemonic.deriveAddress({
    index: 0,
    type: KeyManagement.AddressType.External
  });

  console.log('');
  console.log(`  Mnemonic:   ${mnemonic}`);
  console.log('');
  console.log(`  Address:    ${derivedAddress.address}`);
  console.log('');
})();
