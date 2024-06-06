import * as AssetId from '../../AssetId.js';
import { Asset } from '../../../src/index.js';

describe('Asset', () => {
  describe('util', () => {
    describe('removeNegativesFromTokenMap', () => {
      it('should delete tokens with negative quantities from a token map', () => {
        const asset = new Map([
          [AssetId.PXL, -100n],
          [AssetId.Unit, 50n],
          [AssetId.TSLA, 0n]
        ]);
        expect(Asset.util.removeNegativesFromTokenMap(asset)).toEqual(
          new Map([
            [AssetId.Unit, 50n],
            [AssetId.TSLA, 0n]
          ])
        );
      });
    });
  });
});
