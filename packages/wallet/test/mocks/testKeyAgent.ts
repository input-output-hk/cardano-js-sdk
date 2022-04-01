import { Cardano } from '@cardano-sdk/core';
import { KeyManagement } from '../../src';

export const getPassword = jest.fn(async () => Buffer.from('password'));

export const networkId = Cardano.NetworkId.testnet;

export const testKeyAgent = () =>
  KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
    getPassword,
    mnemonicWords: KeyManagement.util.generateMnemonicWords(),
    networkId
  });
