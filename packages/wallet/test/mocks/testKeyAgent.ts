import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress } from '../../src/KeyManagement';
import { KeyManagement } from '../../src';

export const getPassword = jest.fn(async () => Buffer.from('password'));

export const networkId = Cardano.NetworkId.testnet;

export const testKeyAgent = async (addresses?: GroupedAddress[]) => {
  const keyAgent = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords({
    getPassword,
    mnemonicWords: KeyManagement.util.generateMnemonicWords(),
    networkId
  });
  if (addresses) {
    keyAgent.knownAddresses.push(...addresses);
  }
  return keyAgent;
};

export const testAsyncKeyAgent = async (addresses?: GroupedAddress[], keyAgentReady = testKeyAgent(addresses)) =>
  KeyManagement.util.createAsyncKeyAgent(await keyAgentReady);
