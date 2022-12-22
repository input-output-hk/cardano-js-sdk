/* eslint-disable sonarjs/no-duplicate-string */
import {
  AccountKeyDerivationPath,
  AddressType,
  KeyAgentBase,
  KeyAgentType,
  KeyRole,
  SerializableInMemoryKeyAgentData
} from '../src';
import { CML, Cardano } from '@cardano-sdk/core';
import { dummyLogger } from 'ts-log';

const ACCOUNT_INDEX = 1;

class MockKeyAgent extends KeyAgentBase {
  constructor(data: SerializableInMemoryKeyAgentData) {
    super(data, { inputResolver: { resolveInputAddress: () => Promise.resolve(null) }, logger: dummyLogger });
  }

  serializableDataImpl = jest.fn();
  signBlob = jest.fn();
  exportRootPrivateKey = jest.fn();
  signTransaction = jest.fn();
  signVotingMetadata = jest.fn();
  exportExtendedKeyPair = jest.fn();
  deriveCmlPublicKeyPublic(derivationPath: AccountKeyDerivationPath) {
    return this.deriveCmlPublicKey(derivationPath);
  }
}

describe('KeyAgentBase', () => {
  let keyAgent: MockKeyAgent;

  beforeAll(() => {
    keyAgent = new MockKeyAgent({
      __typename: KeyAgentType.InMemory,
      accountIndex: ACCOUNT_INDEX,
      chainId: Cardano.ChainIds.Preview,
      encryptedRootPrivateKeyBytes: [],
      extendedAccountPublicKey: Cardano.Bip32PublicKey(
        // eslint-disable-next-line max-len
        'fc5ab25e830b67c47d0a17411bf7fdabf711a597fb6cf04102734b0a2934ceaaa65ff5e7c52498d52c07b8ddfcd436fc2b4d2775e2984a49d0c79f65ceee4779'
      ),
      knownAddresses: []
    });
  });

  // eslint-disable-next-line max-len
  // extpubkey:  return '781ad7d97e043e3790e6a94111e2e65b5a5e584a3e542f4655f7794f80d2a081ee571e58e8982b6a549d9090df6d86b6bb2afc69a226eee44ac7f3e3e1da9a14';

  test('deriveAddress either derives a new address, or returns existing with matching type and index', async () => {
    const paymentKey = 'b524f4627318819891efe52da641e05604168e508c3cc9f3e13945f21b69afa0';
    const stakeKey = '6a27d881ef58bd3816f60c05a5fbe872726e76fc239985fde9dcb9a8d7e582e8';
    keyAgent.derivePublicKey = jest.fn().mockResolvedValueOnce(paymentKey).mockResolvedValueOnce(stakeKey);
    const initialAddresses = keyAgent.knownAddresses;

    const index = 1;
    const type = AddressType.External;
    const address = await keyAgent.deriveAddress({ index, type });

    expect(address.index).toBe(index);
    expect(address.type).toBe(type);
    expect(address.accountIndex).toBe(ACCOUNT_INDEX);
    expect(address.networkId).toBe(Cardano.ChainIds.Preview.networkId);
    expect(address.address.startsWith('addr_test')).toBe(true);
    expect(address.rewardAccount.startsWith('stake_test')).toBe(true);
    expect(keyAgent.knownAddresses).toHaveLength(1);
    // creates a new array obj
    expect(keyAgent.knownAddresses).not.toBe(initialAddresses);

    const sameAddress = await keyAgent.deriveAddress({ index, type });
    expect(sameAddress.address).toEqual(address.address);
    expect(keyAgent.knownAddresses.length).toEqual(1);
  });

  test('derivePublicKey', async () => {
    const externalPublicKey = await keyAgent.derivePublicKey({ index: 1, role: KeyRole.External });
    expect(typeof externalPublicKey).toBe('string');
    const stakePublicKey = await keyAgent.derivePublicKey({ index: 1, role: KeyRole.Stake });
    expect(typeof stakePublicKey).toBe('string');
  });

  test('deriveCMLPublicKey', async () => {
    expect(await keyAgent.deriveCmlPublicKeyPublic({ index: 0, role: KeyRole.External })).toBeInstanceOf(CML.PublicKey);
  });
});
