import { mapTokenMap } from '../../src/transformers/assets.js';
import { mintTokenMap } from '../testData.js';
import type { Cardano } from '@cardano-sdk/core';

describe('assets', () => {
  describe('mapTokenMap', () => {
    it('returns undefined when given an undefined token map', async () => {
      const tokeMap: Cardano.TokenMap | undefined = undefined;
      const trezorAssets = mapTokenMap(tokeMap);
      expect(trezorAssets).toBeUndefined();
    });

    it('can map a valid token map to asset group', async () => {
      const trezorAssets = mapTokenMap(mintTokenMap);
      expect(trezorAssets).toEqual([
        {
          policyId: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
          tokenAmounts: [{ amount: '20', assetNameBytes: '' }]
        },
        {
          policyId: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82',
          tokenAmounts: [{ amount: '-50', assetNameBytes: '54534c41' }]
        },
        {
          policyId: '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373',
          tokenAmounts: [
            { amount: '40', assetNameBytes: '' },
            { amount: '30', assetNameBytes: '504154415445' }
          ]
        }
      ]);
    });
  });
});
