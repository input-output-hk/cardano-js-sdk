/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/no-floating-promises */
import { AddressType, InMemoryKeyAgent, util } from '@cardano-sdk/key-management';
import { Cardano } from '@cardano-sdk/core';

/**
 * Generates a new set of Mnemonic words and prints them to the console.
 */
(async () => {
  let mnemonic = '';
  const mnemonicArray = util.generateMnemonicWords();
  for (const word of mnemonicArray) mnemonic += `${word} `;

  const keyAgentFromMnemonic = await InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      getPassword: async () => Buffer.from(''),
      mnemonicWords: mnemonicArray,
      networkId: Cardano.NetworkId.testnet
    },
    { inputResolver: { resolveInputAddress: async () => null } }
  );

  const derivedAddress = await keyAgentFromMnemonic.deriveAddress({
    index: 0,
    type: AddressType.External
  });

  console.log('');
  console.log(`  Mnemonic:   ${mnemonic}`);
  console.log('');
  console.log(`  Address:    ${derivedAddress.address}`);
  console.log('');
})();
