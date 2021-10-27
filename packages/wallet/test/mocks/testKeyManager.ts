import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

export const testKeyManager = () =>
  KeyManagement.createInMemoryKeyManager({
    mnemonicWords: KeyManagement.util.generateMnemonicWords(),
    networkId: Cardano.NetworkId.testnet,
    password: ''
  });
