import { CardanoSerializationLib, loadCardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { Asset } from '@cardano-sdk/core';
import {
  transactionOutputsToArray,
  ValueQuantities,
  valueQuantitiesToValue,
  valueToValueQuantities
} from '../src/util';
import { TestUtils, createCslTestUtils, TSLA_Asset, PXL_Asset } from './util';

describe('util', () => {
  let csl: CardanoSerializationLib;
  let testUtils: TestUtils;
  beforeAll(async () => {
    csl = await loadCardanoSerializationLib();
    testUtils = createCslTestUtils(csl);
  });

  describe('valueQuantitiesToValue', () => {
    it('coin only', () => {
      const quantities = { coins: 100_000n };
      const value = valueQuantitiesToValue(quantities, csl);
      expect(value.coin().to_str()).toEqual(quantities.coins.toString());
      expect(value.multiasset()).toBeUndefined();
    });
    it('coin with assets', () => {
      const quantities: ValueQuantities = { coins: 100_000n, assets: { [TSLA_Asset]: 100n, [PXL_Asset]: 200n } };
      const value = valueQuantitiesToValue(quantities, csl);
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
      const value = valueQuantitiesToValue({ coins, assets }, csl);
      const quantities = valueToValueQuantities(value);
      expect(quantities.coins).toEqual(coins);
      expect(quantities.assets).toEqual(assets);
    });
  });

  it('transactionOutputsToArray', () => {
    const quantities = [10_000n, 20_000n].map((coins) => ({ coins }));
    const outputsObj = testUtils.createOutputsObj(quantities.map((q) => testUtils.createOutput(q)));
    const result = transactionOutputsToArray(outputsObj);
    expect(result.length).toBe(quantities.length);
    // Would test whether it's the same objects instead,
    // but TransactionOutputs.add seems to create a new object.
    expect(result.map((r) => valueToValueQuantities(r.amount()))).toEqual(quantities);
  });
});
