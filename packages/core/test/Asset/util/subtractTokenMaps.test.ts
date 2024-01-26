import * as AssetIds from '../../AssetId';
import { Asset } from '../../../src';

describe('Asset', () => {
  describe('util', () => {
    describe('subtractTokenMaps', () => {
      it('should subtract quantities correctly when all assets have the same tokens', () => {
        const initialAsset = new Map([
          [AssetIds.PXL, 100n],
          [AssetIds.Unit, 50n]
        ]);
        const asset2 = new Map([
          [AssetIds.PXL, 23n],
          [AssetIds.Unit, 20n]
        ]);
        expect(Asset.util.subtractTokenMaps([initialAsset, asset2])).toEqual(
          new Map([
            [AssetIds.PXL, 77n],
            [AssetIds.Unit, 30n]
          ])
        );
      });
      it('should delete tokens from result when quantity is 0', () => {
        const initialAsset = new Map([
          [AssetIds.PXL, 100n],
          [AssetIds.Unit, 50n]
        ]);
        const asset2 = new Map([
          [AssetIds.PXL, 23n],
          [AssetIds.Unit, 50n]
        ]);
        expect(Asset.util.subtractTokenMaps([initialAsset, asset2])).toEqual(new Map([[AssetIds.PXL, 77n]]));
      });
      it('should be able to return negative quantities', () => {
        const initialAsset = new Map([
          [AssetIds.PXL, 100n],
          [AssetIds.Unit, 50n]
        ]);
        const asset2 = new Map([
          [AssetIds.PXL, 173n],
          [AssetIds.Unit, 50n]
        ]);
        const asset3 = new Map([[AssetIds.TSLA, 44n]]);
        expect(Asset.util.subtractTokenMaps([initialAsset, asset2, asset3])).toEqual(
          new Map([
            [AssetIds.PXL, -73n],
            [AssetIds.TSLA, -44n]
          ])
        );
      });
      it('should not change the first element of the array', () => {
        const asset1 = new Map([[AssetIds.PXL, 10n]]);

        const asset2 = new Map([[AssetIds.PXL, 5n]]);

        Asset.util.subtractTokenMaps([asset1, asset2]);

        expect(asset1.get(AssetIds.PXL)).toBe(10n);
      });

      it('should subtract even if the asset is missing in one of the maps', () => {
        const asset1 = new Map([
          [AssetIds.PXL, 1000n],
          [AssetIds.Unit, 12n]
        ]);

        const asset2 = new Map([
          [AssetIds.TSLA, 2n],
          [AssetIds.PXL, 9n],
          [AssetIds.Unit, 1120n]
        ]);

        const result = Asset.util.subtractTokenMaps([asset1, asset2]);

        expect(result!.get(AssetIds.PXL)).toBe(991n);
        expect(result!.get(AssetIds.Unit)).toBe(-1108n);
        expect(result!.get(AssetIds.TSLA)).toBe(-2n);

        const result2 = Asset.util.subtractTokenMaps([asset2, asset1]);

        expect(result2!.get(AssetIds.PXL)).toBe(-991n);
        expect(result2!.get(AssetIds.Unit)).toBe(1108n);
        expect(result2!.get(AssetIds.TSLA)).toBe(2n);
      });
    });
  });
});
