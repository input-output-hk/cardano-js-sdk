import {
  AddressType,
  CommunicationType,
  GetPassword,
  KeyAgentDependencies,
  KeyAgentType,
  SerializableInMemoryKeyAgentData,
  SerializableLedgerKeyAgentData,
  SerializableTrezorKeyAgentData,
  restoreKeyAgent
} from '../src';
import { Cardano } from '@cardano-sdk/core';
import { InvalidSerializableDataError } from '../src/errors';
import { STAKE_KEY_DERIVATION_PATH } from '../src/util';

describe('KeyManagement/restoreKeyAgent', () => {
  const dependencies: KeyAgentDependencies = { inputResolver: { resolveInputAddress: jest.fn() } }; // not called

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

    const address = Cardano.Address(
      'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
    );

    const extendedAccountPublicKey = Cardano.Bip32PublicKey(
      // eslint-disable-next-line max-len
      '6199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d396199186adb51974690d7247d2646097d2c62763b767b528816fb7ed3f9f55d39'
    );

    const rewardAccount = Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr');

    const inMemoryKeyAgentDataWithoutStakeDerivationPath: SerializableInMemoryKeyAgentData = {
      __typename: KeyAgentType.InMemory,
      accountIndex: 0,
      encryptedRootPrivateKeyBytes,
      extendedAccountPublicKey,
      knownAddresses: [
        {
          accountIndex: 0,
          address,
          index: 0,
          networkId: Cardano.NetworkId.Mainnet,
          rewardAccount,
          type: AddressType.External
        }
      ],
      networkId: 0
    };

    const inMemoryKeyAgentData: SerializableInMemoryKeyAgentData = {
      __typename: KeyAgentType.InMemory,
      accountIndex: 0,
      encryptedRootPrivateKeyBytes,
      extendedAccountPublicKey,
      knownAddresses: [
        {
          accountIndex: 0,
          address,
          index: 0,
          networkId: Cardano.NetworkId.Mainnet,
          rewardAccount,
          stakeKeyDerivationPath: STAKE_KEY_DERIVATION_PATH,
          type: AddressType.External
        }
      ],
      networkId: 0
    };
    // eslint-disable-next-line unicorn/consistent-function-scoping
    const getPassword: GetPassword = async () => Buffer.from('password');

    it('assumes default stakeKeyDerivationPath if not present in serializable data', async () => {
      expect.assertions(1);
      const keyAgent = await restoreKeyAgent(inMemoryKeyAgentDataWithoutStakeDerivationPath, dependencies, getPassword);

      for (const knownAddress of keyAgent.knownAddresses) {
        expect(knownAddress.stakeKeyDerivationPath).toBe(STAKE_KEY_DERIVATION_PATH);
      }
    });

    it('can restore key manager from valid data and password', async () => {
      const keyAgent = await restoreKeyAgent(inMemoryKeyAgentData, dependencies, getPassword);
      expect(keyAgent.knownAddresses).toBe(inMemoryKeyAgentData.knownAddresses);
    });

    it('throws when attempting to restore key manager from valid data and no password', async () => {
      await expect(() => restoreKeyAgent(inMemoryKeyAgentData, dependencies)).rejects.toThrowError(
        new InvalidSerializableDataError('Expected "getPassword" in RestoreKeyAgentProps for InMemoryKeyAgent"')
      );
    });

    it('does not attempt to decrypt private key on restoration', async () => {
      // invalid password, would throw if it attempts to decrypt
      await expect(
        restoreKeyAgent(inMemoryKeyAgentData, dependencies, async () => Buffer.from('123'))
      ).resolves.not.toThrow();
    });
  });

  describe('LedgerKeyAgent', () => {
    const ledgerKeyAgentData: SerializableLedgerKeyAgentData = {
      __typename: KeyAgentType.Ledger,
      accountIndex: 0,
      communicationType: CommunicationType.Node,
      extendedAccountPublicKey: Cardano.Bip32PublicKey(
        // eslint-disable-next-line max-len
        'fc5ab25e830b67c47d0a17411bf7fdabf711a597fb6cf04102734b0a2934ceaaa65ff5e7c52498d52c07b8ddfcd436fc2b4d2775e2984a49d0c79f65ceee4779'
      ),
      knownAddresses: [
        {
          accountIndex: 0,
          address: Cardano.Address(
            'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
          ),
          index: 0,
          networkId: Cardano.NetworkId.Mainnet,
          rewardAccount: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'),
          stakeKeyDerivationPath: STAKE_KEY_DERIVATION_PATH,
          type: AddressType.External
        }
      ],
      networkId: 0,
      protocolMagic: 1_097_911_063
    };

    it('can restore key manager from valid data', async () => {
      const keyAgent = await restoreKeyAgent(ledgerKeyAgentData, dependencies);
      expect(keyAgent.knownAddresses).toBe(ledgerKeyAgentData.knownAddresses);
    });
  });

  describe('TrezorKeyAgent', () => {
    const trezorKeyAgentData: SerializableTrezorKeyAgentData = {
      __typename: KeyAgentType.Trezor,
      accountIndex: 0,
      extendedAccountPublicKey: Cardano.Bip32PublicKey(
        // eslint-disable-next-line max-len
        'fc5ab25e830b67c47d0a17411bf7fdabf711a597fb6cf04102734b0a2934ceaaa65ff5e7c52498d52c07b8ddfcd436fc2b4d2775e2984a49d0c79f65ceee4779'
      ),
      knownAddresses: [
        {
          accountIndex: 0,
          address: Cardano.Address(
            'addr1qx52knza2h5x090n4a5r7yraz3pwcamk9ppvuh7e26nfks7pnmhxqavtqy02zezklh27jt9r6z62sav3mugappdc7xnskxy2pn'
          ),
          index: 0,
          networkId: Cardano.NetworkId.Mainnet,
          rewardAccount: Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr'),
          stakeKeyDerivationPath: STAKE_KEY_DERIVATION_PATH,
          type: AddressType.External
        }
      ],
      networkId: 0,
      protocolMagic: 1_097_911_063,
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
      expect(keyAgent.knownAddresses).toBe(trezorKeyAgentData.knownAddresses);
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
      new InvalidSerializableDataError("Restoring key agent of __typename 'OTHER' is not implemented")
    );
  });
});
