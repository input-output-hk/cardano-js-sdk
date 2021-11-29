import { Cardano } from '../../../src';

describe('Cardano/types/StakePool', () => {
  it('PoolId() accepts a valid pool id bech32 string', () => {
    expect(() => Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh')).not.toThrow();
  });

  it('PoolIdHex() accepts a valid pool id hex string', () => {
    expect(() => Cardano.PoolIdHex('e4b1c8ec89415ce6349755a1aa44b4affbb5f1248ff29943d190c715')).not.toThrow();
  });

  it('PoolmdVkey() accepts a valid vrf verification key bech32 poolmd_vk prefix', () => {
    expect(() =>
      Cardano.PoolmdVkey('poolmd_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4stmm43m')
    ).not.toThrow();
  });
});
