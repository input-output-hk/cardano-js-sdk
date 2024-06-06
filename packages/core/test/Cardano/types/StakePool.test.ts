import * as Crypto from '@cardano-sdk/crypto';
import { Cardano } from '../../../src/index.js';

describe('Cardano/types/StakePool', () => {
  it('PoolId() accepts a valid pool id bech32 string', () => {
    expect(() => Cardano.PoolId('pool1zuevzm3xlrhmwjw87ec38mzs02tlkwec9wxpgafcaykmwg7efhh')).not.toThrow();
  });

  it('PoolId.fromKeyHash() returns valid pool id encoded as a bech32 string', () => {
    const poolId = Cardano.PoolId.fromKeyHash(
      Crypto.Ed25519KeyHashHex('594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0')
    );
    expect(poolId).toEqual(Cardano.PoolId('pool1t9xlrjyk76c96jltaspgwcnulq6pdkmhnge8xgza8ku7qvpsy9r'));
  });

  it('PoolId.toKeyHash() returns the key hash encoded in the pool id', () => {
    const keyHash = Cardano.PoolId.toKeyHash(
      Cardano.PoolId('pool1t9xlrjyk76c96jltaspgwcnulq6pdkmhnge8xgza8ku7qvpsy9r')
    );
    expect(keyHash).toEqual(Crypto.Ed25519KeyHashHex('594df1c896f6b05d4bebec0287627cf83416db779a3273205d3db9e0'));
  });

  it('PoolIdHex() accepts a valid pool id hex string', () => {
    expect(() => Cardano.PoolIdHex('e4b1c8ec89415ce6349755a1aa44b4affbb5f1248ff29943d190c715')).not.toThrow();
  });

  it('PoolmdVkey() accepts a valid vrf verification key bech32 poolmd_vk prefix', () => {
    expect(() =>
      Cardano.PoolMdVk('poolmd_vk19j362pkr4t9y0m3qxgmrv0365vd7c4ze03ny4jh84q8agjy4ep4stmm43m')
    ).not.toThrow();
  });
});
