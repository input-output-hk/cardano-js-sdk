import { Cardano } from '../../../src';

describe('ScriptAddress', () => {
  it('accepts a valid mainnet script address', () => {
    expect(() => Cardano.ScriptAddress('addr1wydrmqekah3t8vrqlkhkcnwdxpq5m3wqhq7r6ukwh5yy8pqah05r0')).not.toThrow();
  });

  it('accepts a valid testnet script address', () => {
    expect(() =>
      Cardano.ScriptAddress('addr_test1wqdrmqekah3t8vrqlkhkcnwdxpq5m3wqhq7r6ukwh5yy8pqxlmgv2')
    ).not.toThrow();
  });

  it.skip('throws an error when passing a payment address', () => {
    expect(() =>
      Cardano.ScriptAddress(
        'addr_test1qz2fxv2umyhttkxyxp8x0dlpdt3k6cwng5pxj3jhsydzer3jcu5d8ps7zex2k2xt3uqxgjqnnj83ws8lhrn648jjxtwq2ytjqp'
      )
    ).toThrow();
  });

  it.skip('throws an error when passing a script address with staking', () => {
    expect(() =>
      Cardano.ScriptAddress(
        'addr_test1zqdrmqekah3t8vrqlkhkcnwdxpq5m3wqhq7r6ukwh5yy8py0dxlg6c3adtnjg6yzeuwt9wvjzdq64chdrhchlpsvapdqcjjepv'
      )
    ).toThrow();
  });

  it('throws an error if address is invalid', () => {
    // Valid address but it is a reward address
    expect(() => Cardano.ScriptAddress('stake_test1up7pvfq8zn4quy45r2g572290p9vf99mr9tn7r9xrgy2l2qdsf58d')).toThrow();
    // Does not match any of the supported formats
    expect(() => Cardano.ScriptAddress('nonHex$string')).toThrow();
    // Hex string but it's not an address
    expect(() => Cardano.ScriptAddress('deadbeef')).toThrow();
  });
});
