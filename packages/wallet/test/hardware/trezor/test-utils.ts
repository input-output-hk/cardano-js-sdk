import * as Crypto from '@cardano-sdk/crypto';
import { CommunicationType, TrezorConfig } from '@cardano-sdk/key-management';
import { dummyLogger as logger } from 'ts-log';

/** Shared Trezor configuration for hardware tests */
export const trezorConfig: TrezorConfig = {
  communicationType: CommunicationType.Node,
  manifest: {
    appUrl: 'https://your.application.com',
    email: 'email@developer.com'
  },
  shouldHandlePassphrase: true
};

/** Creates shared key agent dependencies for tests */
export const createKeyAgentDependencies = async () => ({
  bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(),
  logger
});
