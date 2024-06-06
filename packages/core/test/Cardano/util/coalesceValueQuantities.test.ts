import * as AssetId from '../../AssetId.js';
import { coalesceValueQuantities } from '../../../src/index.js';
import type { Cardano } from '../../../src/index.js';

describe('Cardano.util.coalesceValueQuantities', () => {
  it('coin only', () => {
    const q1: Cardano.Value = { coins: 50n };
    const q2: Cardano.Value = { coins: 100n };
    expect(coalesceValueQuantities([q1, q2])).toEqual({ coins: 150n });
  });
  it('coin and assets', () => {
    const q1: Cardano.Value = {
      assets: new Map([
        [AssetId.PXL, 100n],
        [AssetId.TSLA, 50n]
      ]),
      coins: 50n
    };
    const q2: Cardano.Value = { coins: 100n };
    const q3: Cardano.Value = {
      assets: new Map([[AssetId.TSLA, 20n]]),
      coins: 20n
    };
    expect(coalesceValueQuantities([q1, q2, q3])).toEqual({
      assets: new Map([
        [AssetId.PXL, 100n],
        [AssetId.TSLA, 70n]
      ]),
      coins: 170n
    });
  });
  it('returns 0 coins on empty array', () => {
    expect(coalesceValueQuantities([])).toEqual({ coins: 0n });
  });
});
