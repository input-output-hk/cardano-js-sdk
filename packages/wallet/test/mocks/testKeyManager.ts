import { Cardano, CardanoSerializationLib } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

export const testKeyManager = (csl: CardanoSerializationLib) =>
  KeyManagement.createInMemoryKeyManager({
    csl,
    mnemonicWords: KeyManagement.util.generateMnemonicWords(),
    password: '',
    networkId: Cardano.NetworkId.testnet
  });
