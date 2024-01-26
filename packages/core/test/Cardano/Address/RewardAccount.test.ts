import * as Crypto from '@cardano-sdk/crypto';
import * as cip19TestVectors from '../../../../util-dev/src/Cip19TestVectors';
import { Cardano } from '../../../src';
import { typedBech32 } from '@cardano-sdk/util';

jest.mock('@cardano-sdk/util', () => {
  const actual = jest.requireActual('@cardano-sdk/util');
  return {
    ...actual,
    typedBech32: jest.fn().mockImplementation((...args) => actual.typedBech32(...args))
  };
});

describe('Cardano/Address/RewardAccount', () => {
  it('RewardAccount() accepts a valid mainnet stake key bech32 and is implemented using util.typedBech32', () => {
    expect(() => Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')).not.toThrow();
    expect(typedBech32).toBeCalledWith(
      'stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr',
      ['stake', 'stake_test'],
      47
    );
  });

  it('RewardAccount() accepts a valid testnet stake key bech32', () => {
    expect(() =>
      Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
    ).not.toThrow();
  });

  describe('createRewardAccount', () => {
    const keyHash = Crypto.Ed25519KeyHashHex('f15db05f56035465bf8900a09bdaa16c3d8b8244fea686524408dd80');

    it('creates a mainnet address', () => {
      const rewardAccount = Cardano.createRewardAccount(keyHash, Cardano.NetworkId.Mainnet);
      expect(rewardAccount.startsWith('stake')).toBe(true);
      expect(rewardAccount.startsWith('stake_test')).toBe(false);
    });

    it('creates a testnet address', () => {
      const rewardAccount = Cardano.createRewardAccount(keyHash, Cardano.NetworkId.Testnet);
      expect(rewardAccount.startsWith('stake_test')).toBe(true);
    });
  });

  describe('fromCredential', () => {
    it('creates can create a reward account given a credential and a network id', () => {
      const rewardAccount = Cardano.RewardAccount.fromCredential(
        cip19TestVectors.KEY_STAKE_CREDENTIAL,
        Cardano.NetworkId.Mainnet
      );
      expect(rewardAccount).toBe(cip19TestVectors.rewardKey);
    });
  });

  describe('toNetworkId', () => {
    it('get the correct network id from a reward account', () => {
      expect(Cardano.RewardAccount.toNetworkId(Cardano.RewardAccount(cip19TestVectors.rewardKey))).toBe(
        Cardano.NetworkId.Mainnet
      );
    });
  });
});
