import * as Crypto from '@cardano-sdk/crypto';
import { AddressType, KeyAgentBase, KeyAgentType, KeyRole, SerializableInMemoryKeyAgentData } from '../src';
import { Cardano } from '@cardano-sdk/core';
import { dummyLogger } from 'ts-log';

const ACCOUNT_INDEX = 1;
const bip32Ed25519 = new Crypto.SodiumBip32Ed25519();

class MockKeyAgent extends KeyAgentBase {
  constructor(data: SerializableInMemoryKeyAgentData) {
    super(data, {
      bip32Ed25519,
      logger: dummyLogger
    });
  }

  serializableDataImpl = jest.fn();
  signBlob = jest.fn();
  exportRootPrivateKey = jest.fn();
  signTransaction = jest.fn();
  signVotingMetadata = jest.fn();
  exportExtendedKeyPair = jest.fn();
}

describe('KeyAgentBase', () => {
  let keyAgent: MockKeyAgent;

  beforeEach(() => {
    keyAgent = new MockKeyAgent({
      __typename: KeyAgentType.InMemory,
      accountIndex: ACCOUNT_INDEX,
      chainId: Cardano.ChainIds.Preview,
      encryptedRootPrivateKeyBytes: [],
      extendedAccountPublicKey: Crypto.Bip32PublicKeyHex(
        // eslint-disable-next-line max-len
        'fc5ab25e830b67c47d0a17411bf7fdabf711a597fb6cf04102734b0a2934ceaaa65ff5e7c52498d52c07b8ddfcd436fc2b4d2775e2984a49d0c79f65ceee4779'
      )
    });
  });

  test('deriveAddress derives a new address', async () => {
    const index = 1;
    const type = AddressType.External;
    const address = await keyAgent.deriveAddress({ index, type }, 0);

    expect(address.index).toBe(index);
    expect(address.type).toBe(type);
    expect(address.accountIndex).toBe(ACCOUNT_INDEX);
    expect(address.networkId).toBe(Cardano.ChainIds.Preview.networkId);
    expect(address.address.startsWith('addr_test')).toBe(true);
    expect(address.rewardAccount.startsWith('stake_test')).toBe(true);
  });

  test('derivePublicKey', async () => {
    const externalPublicKey = await keyAgent.derivePublicKey({ index: 1, role: KeyRole.External });
    expect(typeof externalPublicKey).toBe('string');
    const stakePublicKey = await keyAgent.derivePublicKey({ index: 1, role: KeyRole.Stake });
    expect(typeof stakePublicKey).toBe('string');
    const dRepPublicKey = await keyAgent.derivePublicKey({ index: 0, role: KeyRole.DRep });
    expect(typeof dRepPublicKey).toBe('string');
  });
});
