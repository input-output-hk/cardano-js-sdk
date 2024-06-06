import { mapTokenMap } from '../../src/transformers/assets.js';
import { mintTokenMap } from '../testData.js';
import type { Cardano } from '@cardano-sdk/core';

describe('assets', () => {
  describe('mapTokenMap', () => {
    it('returns null when given an undefined token map', async () => {
      const tokeMap: Cardano.TokenMap | undefined = undefined;
      const ledgerAssets = mapTokenMap(tokeMap);

      expect(ledgerAssets).toEqual(null);
    });

    it('can map a valid token map to asset group', async () => {
      const ledgerAssets = mapTokenMap(mintTokenMap);

      expect(ledgerAssets).toEqual([
        {
          policyIdHex: '2a286ad895d091f2b3d168a6091ad2627d30a72761a5bc36eef00740',
          tokens: [{ amount: 20n, assetNameHex: '' }]
        },
        {
          policyIdHex: '659f2917fb63f12b33667463ee575eeac1845bbc736b9c0bbc40ba82',
          tokens: [{ amount: -50n, assetNameHex: '54534c41' }]
        },
        {
          policyIdHex: '7eae28af2208be856f7a119668ae52a49b73725e326dc16579dcc373',
          tokens: [
            { amount: 40n, assetNameHex: '' },
            { amount: 30n, assetNameHex: '504154415445' }
          ]
        }
      ]);
    });
  });
});
