/* eslint-disable no-console */
/* eslint-disable @typescript-eslint/no-floating-promises */
import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, InMemoryKeyAgent, KeyPurpose, util } from '@cardano-sdk/key-management';
import { localNetworkChainId } from '../util';

/** Generates a new set of Mnemonic words and prints them to the console. */
(async () => {
  let mnemonic = '';
  const mnemonicArray = util.generateMnemonicWords();
  for (const word of mnemonicArray) mnemonic += `${word} `;

  const keyAgentFromMnemonic = await InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      chainId: localNetworkChainId,
      getPassphrase: async () => Buffer.from(''),
      mnemonicWords: mnemonicArray,
      purpose: KeyPurpose.STANDARD
    },
    {
      bip32Ed25519: new Crypto.SodiumBip32Ed25519(),
      logger: console
    }
  );

  const derivedAddress = await keyAgentFromMnemonic.deriveAddress(
    {
      index: 0,
      type: AddressType.External
    },
    0
  );

  console.log('');
  console.log(`  Mnemonic:   ${mnemonic}`);
  console.log('');
  console.log(`  Address:    ${derivedAddress.address}`);
  console.log('');
})();
