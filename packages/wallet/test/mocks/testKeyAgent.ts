import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

export const testKeyAgent = () =>
  KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
    getPassword: async () => Buffer.from('password'),
    mnemonicWords: KeyManagement.util.generateMnemonicWords(),
    networkId: Cardano.NetworkId.testnet
  });
