import { Cardano } from '../../../src';
import { typedBech32 } from '@cardano-sdk/util';

jest.mock('@cardano-sdk/util', () => {
  const actual = jest.requireActual('@cardano-sdk/util');
  return {
    ...actual,
    typedBech32: jest.fn().mockImplementation((...args) => actual.typedBech32(...args))
  };
});

describe('Cardano/types/RewardAccount', () => {
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
});
