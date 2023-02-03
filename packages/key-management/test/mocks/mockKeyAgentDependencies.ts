import { CML } from '@cardano-sdk/core';
import { CmlBip32Ed25519 } from '@cardano-sdk/crypto';
import { KeyAgentDependencies } from '../../src/';
import { dummyLogger } from 'ts-log';

export const mockKeyAgentDependencies = (): jest.Mocked<KeyAgentDependencies> => ({
  bip32Ed25519: new CmlBip32Ed25519(CML),
  inputResolver: {
    resolveInputAddress: jest.fn().mockResolvedValue(null)
  },
  logger: dummyLogger
});
