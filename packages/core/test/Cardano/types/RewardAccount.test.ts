import { Cardano } from '../../../src';

describe('Cardano/types/RewardAccount', () => {
  it('RewardAccount() accepts a valid mainnet stake key bech32', () => {
    expect(() => Cardano.RewardAccount('stake1u89sasnfyjtmgk8ydqfv3fdl52f36x3djedfnzfc9rkgzrcss5vgr')).not.toThrow();
  });

  it('RewardAccount() accepts a valid testnet stake key bech32', () => {
    expect(() =>
      Cardano.RewardAccount('stake_test1uqfu74w3wh4gfzu8m6e7j987h4lq9r3t7ef5gaw497uu85qsqfy27')
    ).not.toThrow();
  });
});
