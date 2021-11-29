import { Cardano } from '../../../src';

jest.mock('../../../src/Cardano/util/primitives', () => {
  const actual = jest.requireActual('../../../src/Cardano/util/primitives');
  return {
    typedBech32: jest.fn().mockImplementation((...args) => actual.typedBech32(...args))
  };
});

describe('Cardano/types/RewardAccount', () => {
  it('RewardAccount() accepts a valid mainnet stake key bech32 and is implemented using util.typedBech32', () => {
    expect(() => Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')).not.toThrow();
    expect(Cardano.util.typedBech32).toBeCalledWith(
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
