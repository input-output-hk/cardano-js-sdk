/* eslint-disable sonarjs/no-duplicate-string */
import * as Crypto from '@cardano-sdk/crypto';
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
const bip32Ed25519 = new Crypto.CmlBip32Ed25519(CML);

class MockKeyAgent extends KeyAgentBase {
  constructor(data: SerializableInMemoryKeyAgentData) {
    super(data, {
      bip32Ed25519,
      inputResolver: { resolveInput: () => Promise.resolve(null) },
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
    const address = await keyAgent.deriveAddress({ index, type }, 0);

    expect(address.index).toBe(index);
    expect(address.type).toBe(type);
    expect(address.accountIndex).toBe(ACCOUNT_INDEX);
    expect(address.networkId).toBe(Cardano.ChainIds.Preview.networkId);
    expect(address.address.startsWith('addr_test')).toBe(true);
    expect(address.rewardAccount.startsWith('stake_test')).toBe(true);
    expect(keyAgent.knownAddresses).toHaveLength(1);
    // creates a new array obj
    expect(keyAgent.knownAddresses).not.toBe(initialAddresses);

    const sameAddress = await keyAgent.deriveAddress({ index, type }, 0);
    expect(sameAddress.address).toEqual(address.address);
    expect(keyAgent.knownAddresses.length).toEqual(1);
  });

  test('deriveAddress derives the address with stake key of the given index', async () => {
    const keyMap = new Map<number, string>([
      [0, '0000000000000000000000000000000000000000000000000000000000000000'],
      [1, '1111111111111111111111111111111111111111111111111111111111111111'],
      [2, '2222222222222222222222222222222222222222222222222222222222222222'],
      [3, '3333333333333333333333333333333333333333333333333333333333333333'],
      [4, '4444444444444444444444444444444444444444444444444444444444444444']
    ]);

    keyAgent.derivePublicKey = jest.fn((x: AccountKeyDerivationPath) =>
      Promise.resolve(Crypto.Ed25519PublicKeyHex(keyMap.get(x.index)!))
    );

    const index = 0;
    const type = AddressType.External;
    const addresses = [
      await keyAgent.deriveAddress({ index, type }, 0),
      await keyAgent.deriveAddress({ index, type }, 1),
      await keyAgent.deriveAddress({ index, type }, 2),
      await keyAgent.deriveAddress({ index, type }, 3)
    ];

    expect(addresses[0].stakeKeyDerivationPath).toEqual({ index: 0, role: KeyRole.Stake });
    expect(addresses[0].rewardAccount).toEqual('stake_test1uruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhc8cxn3h');
    expect(addresses[0].address).toEqual(
      'addr_test1qruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhlemj3p5myzdmy2edx089wtcfp4rymmlejkpvng82utg90s4cadlm'
    );

    expect(addresses[1].stakeKeyDerivationPath).toEqual({ index: 1, role: KeyRole.Stake });
    expect(addresses[1].rewardAccount).toEqual('stake_test1uzx0qqs06evy77cnpk6u5q3fc50exjpp5t4s0swl2ykc4jsmh8tej');
    expect(addresses[1].address).toEqual(
      'addr_test1qruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhuv7qpql4jcfaa3xrd4egpzn3gljdyzrghtqlqa75fd3t9qqnvgeq'
    );

    expect(addresses[2].stakeKeyDerivationPath).toEqual({ index: 2, role: KeyRole.Stake });
    expect(addresses[2].rewardAccount).toEqual('stake_test1uqcnxxxatdgmqdmz0rhg72kn3n0egek5s0nqcvfy9ztyltc9cpuz4');
    expect(addresses[2].address).toEqual(
      'addr_test1qruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhe3xvvd6k63kqmky78w3u4d8rxlj3ndfqlxpscjg2ykf7hs8qc48l'
    );

    expect(addresses[3].stakeKeyDerivationPath).toEqual({ index: 3, role: KeyRole.Stake });
    expect(addresses[3].rewardAccount).toEqual('stake_test1urj8hvwxxz0t6pnfttj9ne5leu74shjlg83a8kxww9ft2fqtdhssu');
    expect(addresses[3].address).toEqual(
      'addr_test1qruaegs6djpxaj9vkn8njh9uys63jdaluetqkf5r4w95zhly0wcuvvy7h5rxjkhyt8nflneatp097s0r60vvuu2jk5jq73efq0'
    );
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
