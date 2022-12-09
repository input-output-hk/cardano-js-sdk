import { Cardano } from '@cardano-sdk/core';
import { GroupedAddress, InMemoryKeyAgent, KeyAgentDependencies, util } from '../../src';
import { mockKeyAgentDependencies } from './mockKeyAgentDependencies';

export const getPassword = jest.fn(async () => Buffer.from('password'));

export const testKeyAgent = async (
  addresses?: GroupedAddress[],
  dependencies: KeyAgentDependencies | undefined = mockKeyAgentDependencies()
) => {
  const keyAgent = await InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      getPassword,
      mnemonicWords: util.generateMnemonicWords(),
      networkId: Cardano.NetworkId.testnet
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
  keyAgentReady = testKeyAgent(addresses, dependencies),
  shutdownSpy?: () => void
) => util.createAsyncKeyAgent(await keyAgentReady, shutdownSpy);
