import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '@cardano-sdk/core';
import {
  CommunicationType,
  GetPassphrase,
  KeyAgentDependencies,
  KeyAgentType,
  KeyPurpose,
  SerializableInMemoryKeyAgentData,
  SerializableLedgerKeyAgentData,
  SerializableTrezorKeyAgentData,
  errors
} from '@cardano-sdk/key-management';

import { dummyLogger } from 'ts-log';
import { restoreKeyAgent } from '../../../src';

describe('KeyManagement/restoreKeyAgent', () => {
  let dependencies: KeyAgentDependencies;

  beforeAll(async () => {
    dependencies = {
      bip32Ed25519: await Crypto.SodiumBip32Ed25519.create(),
      logger: dummyLogger
    };
  });

  describe('InMemoryKeyAgent', () => {
    const encryptedRootPrivateKeyBytes = [
      9, 10, 153, 62, 225, 131, 81, 153, 234, 186, 63, 211, 14, 172, 194, 82, 184, 119, 228, 49, 2, 133, 239, 127, 196,
      140, 219, 8, 136, 248, 186, 84, 165, 123, 197, 105, 73, 181, 144, 27, 137, 206, 159, 63, 37, 138, 150, 49, 194,
      164, 58, 66, 200, 97, 242, 184, 110, 11, 39, 106, 131, 156, 196, 138, 219, 29, 7, 71, 117, 172, 111, 88, 44, 103,
      205, 168, 94, 156, 89, 252, 92, 55, 218, 216, 40, 59, 88, 227, 170, 118, 161, 116, 84, 39, 92, 33, 66, 157, 42,
      14, 225, 45, 175, 93, 214, 141, 163, 136, 13, 46, 152, 33, 166, 202, 127, 122, 146, 239, 38, 125, 114, 66, 141,
      241, 161, 163, 19, 81, 122, 125, 149, 49, 175, 149, 111, 48, 138, 254, 189, 69, 35, 135, 62, 177, 43, 152, 95, 7,
      87, 78, 204, 222, 109, 3, 239, 117
    ];

    const extendedAccountPublicKey = Crypto.Bip32PublicKeyHex(
      // eslint-disable-next-line max-len
      '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d396199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
    );

    const inMemoryKeyAgentData: SerializableInMemoryKeyAgentData = {
      __typename: KeyAgentType.InMemory,
      accountIndex: 0,
      chainId: Cardano.ChainIds.Preview,
      encryptedRootPrivateKeyBytes,
      extendedAccountPublicKey,
      purpose: KeyPurpose.STANDARD
    };
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const getPassphrase: GetPassphrase = async () => Buffer.from('password');

    it('can restore key manager from valid data and passphrase', async () => {
      const keyAgent = await restoreKeyAgent(inMemoryKeyAgentData, dependencies, getPassphrase);
      expect(keyAgent.extendedAccountPublicKey).toEqual(inMemoryKeyAgentData.extendedAccountPublicKey);
    });

    it('throws when attempting to restore key manager from valid data and no passphrase', async () => {
      await expect(() => restoreKeyAgent(inMemoryKeyAgentData, dependencies)).rejects.toThrowError(
        new errors.InvalidSerializableDataError(
          'Expected "getPassphrase" in RestoreKeyAgentProps for InMemoryKeyAgent"'
        )
      );
    });

    it('does not attempt to decrypt private key on restoration', async () => {
      // invalid passphrase, would throw if it attempts to decrypt
      await expect(
        restoreKeyAgent(inMemoryKeyAgentData, dependencies, async () => Buffer.from('123'))
      ).resolves.not.toThrow();
    });
  });

  describe('LedgerKeyAgent', () => {
    const ledgerKeyAgentData: SerializableLedgerKeyAgentData = {
      __typename: KeyAgentType.Ledger,
      accountIndex: 0,
      chainId: Cardano.ChainIds.Preprod,
      communicationType: CommunicationType.Node,
      extendedAccountPublicKey: Crypto.Bip32PublicKeyHex(
        // eslint-disable-next-line max-len
        'fc5ab25e830b67c47d0a17411bf7fdabf711a597fb6cf04102734b0a2934ceaaa65ff5e7c52498d52c07b8ddfcd436fc2b4d2775e2984a49d0c79f65ceee4779'
      ),
      purpose: KeyPurpose.STANDARD
    };

    it('can restore key manager from valid data', async () => {
      const keyAgent = await restoreKeyAgent(ledgerKeyAgentData, dependencies);
      expect(keyAgent.extendedAccountPublicKey).toEqual(ledgerKeyAgentData.extendedAccountPublicKey);
    });
  });

  describe('TrezorKeyAgent', () => {
    const trezorKeyAgentData: SerializableTrezorKeyAgentData = {
      __typename: KeyAgentType.Trezor,
      accountIndex: 0,
      chainId: Cardano.ChainIds.Preprod,
      extendedAccountPublicKey: Crypto.Bip32PublicKeyHex(
        // eslint-disable-next-line max-len
        'fc5ab25e830b67c47d0a17411bf7fdabf711a597fb6cf04102734b0a2934ceaaa65ff5e7c52498d52c07b8ddfcd436fc2b4d2775e2984a49d0c79f65ceee4779'
      ),
      purpose: KeyPurpose.STANDARD,
      trezorConfig: {
        communicationType: CommunicationType.Node,
        manifest: {
          appUrl: 'https://your.application.com',
          email: 'email@developer.com'
        }
      }
    };

    it('can restore key manager from valid data', async () => {
      const keyAgent = await restoreKeyAgent(trezorKeyAgentData, dependencies);
      expect(keyAgent.extendedAccountPublicKey).toEqual(trezorKeyAgentData.extendedAccountPublicKey);
    });
  });

  it('throws when attempting to restore key manager of unsupported __typename', async () => {
    await expect(() =>
      restoreKeyAgent(
        {
          __typename: 'OTHER',
          knownAddresses: []
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
        } as any,
        dependencies
      )
    ).rejects.toThrowError(
      new errors.InvalidSerializableDataError("Restoring key agent of __typename 'OTHER' is not implemented")
    );
  });
});
