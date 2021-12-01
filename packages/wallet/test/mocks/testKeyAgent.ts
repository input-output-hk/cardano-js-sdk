import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

export const testKeyManager = () =>
  KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
    authenticate: async () => Buffer.from('password'),
    mnemonicWords: KeyManagement.util.generateMnemonicWords(),
    networkId: Cardano.NetworkId.testnet
  });
