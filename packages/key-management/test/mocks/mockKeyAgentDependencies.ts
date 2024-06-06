import { SodiumBip32Ed25519 } from '@cardano-sdk/crypto';
import { dummyLogger } from 'ts-log';
import type { KeyAgentDependencies } from '../../src/index.js';

export const mockKeyAgentDependencies = (): jest.Mocked<KeyAgentDependencies> => ({
  bip32Ed25519: new SodiumBip32Ed25519(),
  logger: dummyLogger
});
