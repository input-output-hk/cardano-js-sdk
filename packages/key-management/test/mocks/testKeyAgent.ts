import { Cardano } from '@cardano-sdk/core';
import { InMemoryKeyAgent, KeyAgentDependencies, util } from '../../src';
import { mockKeyAgentDependencies } from './mockKeyAgentDependencies';

export const getPassphrase = jest.fn(async () => Buffer.from('password'));

export const testKeyAgent = async (dependencies: KeyAgentDependencies | undefined = mockKeyAgentDependencies()) =>
  InMemoryKeyAgent.fromBip39MnemonicWords(
    {
      chainId: Cardano.ChainIds.Preview,
      getPassphrase,
      mnemonicWords: util.generateMnemonicWords()
    },
    dependencies
  );

export const testAsyncKeyAgent = async (
  dependencies: KeyAgentDependencies | undefined = mockKeyAgentDependencies(),
  keyAgentReady = testKeyAgent(dependencies),
  shutdownSpy?: () => void
) => util.createAsyncKeyAgent(await keyAgentReady, shutdownSpy);
