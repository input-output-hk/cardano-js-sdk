import { CardanoSerializationLib, loadCardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { Asset } from '@cardano-sdk/core';
import { createCslUtils, CslUtils, transactionOutputsToArray, ValueQuantities } from '../src/util';
import { TestUtils, createCslTestUtils, TSLA_Asset, PXL_Asset } from './util';

describe('util', () => {
  let CSL: CardanoSerializationLib;
  let cslUtils: CslUtils;
  let testUtils: TestUtils;
  let assetSerializer: Asset.util.AssetSerializer;
  beforeAll(async () => {
    CSL = await loadCardanoSerializationLib();
    assetSerializer = Asset.util.createAssetSerializer(CSL);
    cslUtils = createCslUtils(CSL, assetSerializer);
    testUtils = createCslTestUtils(CSL);
  });

  describe('createCslUtils', () => {
    describe('valueQuantitiesToValue', () => {
      it('coin only', () => {
        const quantities = { coins: 100_000n };
        const value = cslUtils.valueQuantitiesToValue(quantities);
        expect(value.coin().to_str()).toEqual(quantities.coins.toString());
        expect(value.multiasset()).toBeUndefined();
      });
      it('coin with assets', () => {
        const quantities: ValueQuantities = { coins: 100_000n, assets: { [TSLA_Asset]: 100n, [PXL_Asset]: 200n } };
        const value = cslUtils.valueQuantitiesToValue(quantities);
        expect(value.coin().to_str()).toEqual(quantities.coins.toString());
        const multiasset = value.multiasset();
        expect(multiasset.len()).toBe(2);
        for (const assetId in quantities.assets) {
          const { scriptHash, assetName } = assetSerializer.parseId(assetId);
          const assetQuantity = BigInt(multiasset.get(scriptHash).get(assetName).to_str());
          expect(assetQuantity).toBe(quantities.assets[assetId]);
        }
      });
    });
    describe('valueToValueQuantities', () => {
      it('coin only', () => {
        const coins = 100_000n;
        const value = CSL.Value.new(CSL.BigNum.from_str(coins.toString()));
        const quantities = cslUtils.valueToValueQuantities(value);
        expect(quantities.coins).toEqual(coins);
        expect(quantities.assets).toBeUndefined();
      });
      it('coin with assets', () => {
        const coins = 100_000n;
        const assets = { [TSLA_Asset]: 100n, [PXL_Asset]: 200n };
        const value = cslUtils.valueQuantitiesToValue({ coins, assets });
        const quantities = cslUtils.valueToValueQuantities(value);
        expect(quantities.coins).toEqual(coins);
        expect(quantities.assets).toEqual(assets);
      });
    });
  });

  it('transactionOutputsToArray', () => {
    const quantities = [10_000n, 20_000n].map((coins) => ({ coins }));
    const outputsObj = testUtils.createOutputsObj(quantities.map((q) => testUtils.createOutput(q)));
    const result = transactionOutputsToArray(outputsObj);
    expect(result.length).toBe(quantities.length);
    // Would test whether it's the same objects instead,
    // but TransactionOutputs.add seems to create a new object.
    expect(result.map((r) => cslUtils.valueToValueQuantities(r.amount()))).toEqual(quantities);
  });
});
