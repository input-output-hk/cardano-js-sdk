import * as AssetId from '../../AssetId';
import { Asset } from '../../../src';

describe('Asset', () => {
  describe('util', () => {
    describe('subtractTokenMaps', () => {
      it('should subtract quantities correctly when all assets have the same tokens', () => {
        const initialAsset = new Map([
          [AssetId.PXL, 100n],
          [AssetId.Unit, 50n]
        ]);
        const asset2 = new Map([
          [AssetId.PXL, 23n],
          [AssetId.Unit, 20n]
        ]);
        expect(Asset.util.subtractTokenMaps([initialAsset, asset2])).toEqual(
          new Map([
            [AssetId.PXL, 77n],
            [AssetId.Unit, 30n]
          ])
        );
      });
      it('should delete tokens from result when quantity is 0', () => {
        const initialAsset = new Map([
          [AssetId.PXL, 100n],
          [AssetId.Unit, 50n]
        ]);
        const asset2 = new Map([
          [AssetId.PXL, 23n],
          [AssetId.Unit, 50n]
        ]);
        expect(Asset.util.subtractTokenMaps([initialAsset, asset2])).toEqual(new Map([[AssetId.PXL, 77n]]));
      });
      it('should be able to return negative quantities', () => {
        const initialAsset = new Map([
          [AssetId.PXL, 100n],
          [AssetId.Unit, 50n]
        ]);
        const asset2 = new Map([
          [AssetId.PXL, 173n],
          [AssetId.Unit, 50n]
        ]);
        const asset3 = new Map([[AssetId.TSLA, 44n]]);
        expect(Asset.util.subtractTokenMaps([initialAsset, asset2, asset3])).toEqual(
          new Map([
            [AssetId.PXL, -73n],
            [AssetId.TSLA, -44n]
          ])
        );
      });
    });
  });
});
