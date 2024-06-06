import * as AssetIds from '../../AssetId.js';
import { Asset } from '../../../src/index.js';

describe('Asset', () => {
  describe('util', () => {
    describe('coalesceTokenMaps', () => {
      it('should add quantities correctly when all assets have the same tokens', () => {
        const initialAsset = new Map([
          [AssetIds.PXL, 100n],
          [AssetIds.Unit, 50n]
        ]);
        const asset2 = new Map([
          [AssetIds.PXL, 23n],
          [AssetIds.Unit, 20n]
        ]);
        expect(Asset.util.coalesceTokenMaps([initialAsset, asset2])).toEqual(
          new Map([
            [AssetIds.PXL, 123n],
            [AssetIds.Unit, 70n]
          ])
        );
      });
      it('should be able to return negative quantities', () => {
        const initialAsset = new Map([
          [AssetIds.PXL, 100n],
          [AssetIds.Unit, -150n]
        ]);
        const asset2 = new Map([
          [AssetIds.PXL, 173n],
          [AssetIds.Unit, 50n]
        ]);
        const asset3 = new Map([[AssetIds.TSLA, 44n]]);
        expect(Asset.util.coalesceTokenMaps([initialAsset, asset2, asset3])).toEqual(
          new Map([
            [AssetIds.PXL, 273n],
            [AssetIds.TSLA, 44n],
            [AssetIds.Unit, -100n]
          ])
        );
      });

      it('should add even if the asset is missing in one of the maps', () => {
        const asset1 = new Map([
          [AssetIds.PXL, 1000n],
          [AssetIds.Unit, 12n]
        ]);

        const asset2 = new Map([
          [AssetIds.TSLA, 2n],
          [AssetIds.PXL, 9n],
          [AssetIds.Unit, 1000n]
        ]);

        const result = Asset.util.coalesceTokenMaps([asset1, asset2]);

        expect(result!.get(AssetIds.PXL)).toBe(1009n);
        expect(result!.get(AssetIds.Unit)).toBe(1012n);
        expect(result!.get(AssetIds.TSLA)).toBe(2n);

        const result2 = Asset.util.coalesceTokenMaps([asset2, asset1]);

        expect(result2!.get(AssetIds.PXL)).toBe(1009n);
        expect(result2!.get(AssetIds.Unit)).toBe(1012n);
        expect(result2!.get(AssetIds.TSLA)).toBe(2n);
      });
    });
  });
});
