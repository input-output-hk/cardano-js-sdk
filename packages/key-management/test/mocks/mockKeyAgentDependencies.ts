import { KeyAgentDependencies } from '../../src/';
import { SodiumBip32Ed25519 } from '@cardano-sdk/crypto';
import { dummyLogger } from 'ts-log';

export const mockKeyAgentDependencies = async (): Promise<jest.Mocked<KeyAgentDependencies>> => ({
  bip32Ed25519: await SodiumBip32Ed25519.create(),
  logger: dummyLogger
});
