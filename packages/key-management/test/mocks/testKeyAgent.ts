import { AsyncKeyAgent, InMemoryKeyAgent, KeyAgentDependencies, util } from '../../src';
import { Cardano } from '@cardano-sdk/core';
import { mockKeyAgentDependencies } from './mockKeyAgentDependencies';

export const getPassphrase = jest.fn(async () => Buffer.from('password'));

export const testKeyAgent = async (dependencies?: KeyAgentDependencies) => {
  if (!dependencies) {
    dependencies = await mockKeyAgentDependencies();
  }

  return InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      chainId: Cardano.ChainIds.Preview,
      getPassphrase,
      mnemonicWords: util.generateMnemonicWords()
    },
    dependencies
  );
};

export const testAsyncKeyAgent = async (
  dependencies?: KeyAgentDependencies,
  keyAgentReady?: Promise<InMemoryKeyAgent>,
  shutdownSpy?: () => AsyncKeyAgent
) => {
  if (!dependencies) {
    dependencies = await mockKeyAgentDependencies();
  }

  if (!keyAgentReady) {
    keyAgentReady = testKeyAgent(dependencies);
  }

  return util.createAsyncKeyAgent(await keyAgentReady, shutdownSpy);
};
