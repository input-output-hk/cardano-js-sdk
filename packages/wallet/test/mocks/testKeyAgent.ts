import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, KeyAgentDependencies } from '../../src/KeyManagement';
import { KeyManagement } from '../../src';
import { mockKeyAgentDependencies } from './mockKeyAgentDependencies';

export const getPassword = jest.fn(async () => Buffer.from('password'));

export const networkId = Cardano.NetworkId.testnet;

export const testKeyAgent = async (
  addresses?: GroupedAddress[],
  dependencies: KeyAgentDependencies | undefined = mockKeyAgentDependencies()
) => {
  const keyAgent = await KeyManagement.InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      getPassword,
      mnemonicWords: KeyManagement.util.generateMnemonicWords(),
      networkId
    },
    dependencies
  );
  if (addresses) {
    keyAgent.knownAddresses.push(...addresses);
  }
  return keyAgent;
};

export const testAsyncKeyAgent = async (
  addresses?: GroupedAddress[],
  dependencies: KeyAgentDependencies | undefined = mockKeyAgentDependencies(),
  keyAgentReady = testKeyAgent(addresses, dependencies)
) => KeyManagement.util.createAsyncKeyAgent(await keyAgentReady);
