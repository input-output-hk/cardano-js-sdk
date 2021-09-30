import { CardanoSerializationLib, loadCardanoSerializationLib, Asset } from '@cardano-sdk/core';
import { OgmiosValue, ogmiosValueToCslValue, valueToValueQuantities } from '../src/util';
import { TSLA_Asset, PXL_Asset } from './util';

describe('util', () => {
  let csl: CardanoSerializationLib;
  beforeAll(async () => {
    csl = await loadCardanoSerializationLib();
  });

  describe('ogmiosValueToCslValue', () => {
    it('coin only', () => {
      const quantities = { coins: 100_000n };
      const value = ogmiosValueToCslValue(quantities, csl);
      expect(value.coin().to_str()).toEqual(quantities.coins.toString());
      expect(value.multiasset()).toBeUndefined();
    });
    it('coin with assets', () => {
      const quantities: OgmiosValue = { coins: 100_000n, assets: { [TSLA_Asset]: 100n, [PXL_Asset]: 200n } };
      const value = ogmiosValueToCslValue(quantities, csl);
      expect(value.coin().to_str()).toEqual(quantities.coins.toString());
      const multiasset = value.multiasset();
      expect(multiasset.len()).toBe(2);
      for (const assetId in quantities.assets) {
        const { scriptHash, assetName } = Asset.util.parseAssetId(assetId, csl);
        const assetQuantity = BigInt(multiasset.get(scriptHash).get(assetName).to_str());
        expect(assetQuantity).toBe(quantities.assets[assetId]);
      }
    });
  });
  describe('valueToValueQuantities', () => {
    it('coin only', () => {
      const coins = 100_000n;
      const value = csl.Value.new(csl.BigNum.from_str(coins.toString()));
      const quantities = valueToValueQuantities(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toBeUndefined();
    });
    it('coin with assets', () => {
      const coins = 100_000n;
      const assets = { [TSLA_Asset]: 100n, [PXL_Asset]: 200n };
      const value = ogmiosValueToCslValue({ coins, assets }, csl);
      const quantities = valueToValueQuantities(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toEqual(assets);
    });
  });
});
