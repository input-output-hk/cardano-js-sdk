import * as AssetId from '../../AssetId';
import { Cardano } from '../../../src';

describe('Cardano.util.subtractValueQuantities', () => {
  it('subtracts quantities for coins only', () => {
    const q1: Cardano.Value = { coins: 100n };
    const q2: Cardano.Value = { coins: 50n };
    expect(Cardano.util.subtractValueQuantities([q1, q2])).toEqual({ coins: 50n });
  });
  it('subtracts quantities for coin and assets', () => {
    const q1: Cardano.Value = {
      assets: new Map([
        [AssetId.PXL, 100n],
        [AssetId.TSLA, 50n]
      ]),
      coins: 200n
    };
    const q2: Cardano.Value = { coins: 100n };
    const q3: Cardano.Value = {
      assets: new Map([[AssetId.TSLA, 20n]]),
      coins: 20n
    };
    expect(Cardano.util.subtractValueQuantities([q1, q2, q3])).toEqual({
      assets: new Map([
        [AssetId.PXL, 100n],
        [AssetId.TSLA, 30n]
      ]),
      coins: 80n
    });
  });
  it('does not return assets when quantities are zero', () => {
    const q1: Cardano.Value = {
      assets: new Map([
        [AssetId.PXL, 100n],
        [AssetId.TSLA, 50n]
      ]),
      coins: 200n
    };
    expect(Cardano.util.subtractValueQuantities([q1, q1])).toEqual({ assets: undefined, coins: 0n });
  });
  it('returns negative quantities', () => {
    const q1: Cardano.Value = {
      assets: new Map([
        [AssetId.PXL, 100n],
        [AssetId.TSLA, 50n]
      ]),
      coins: 200n
    };
    const q2: Cardano.Value = { coins: 100n };
    const q3: Cardano.Value = {
      assets: new Map([[AssetId.TSLA, 200n]]),
      coins: 200n
    };
    expect(Cardano.util.subtractValueQuantities([q1, q2, q3])).toEqual({
      assets: new Map([
        [AssetId.PXL, 100n],
        [AssetId.TSLA, -150n]
      ]),
      coins: -100n
    });
  });
  it('returns 0 coins on empty array', () => {
    expect(Cardano.util.subtractValueQuantities([])).toEqual({ coins: 0n });
  });
});
