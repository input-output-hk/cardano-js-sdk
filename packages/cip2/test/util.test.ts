import { CardanoSerializationLib, loadCardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import {
  AssetSerializer,
  coalesceValueQuantities,
  computeMinUtxoValue,
  createAssetSerializer,
  createCslUtils,
  CslUtils,
  transactionOutputsToArray,
  ValueQuantities
} from '@src/util';
import { TestUtils, createCslTestUtils, TSLA_Asset, PXL_Asset } from './util';

describe('util', () => {
  let CSL: CardanoSerializationLib;
  let cslUtils: CslUtils;
  let testUtils: TestUtils;
  let assetSerializer: AssetSerializer;
  beforeAll(async () => {
    CSL = await loadCardanoSerializationLib();
    assetSerializer = createAssetSerializer(CSL);
    cslUtils = createCslUtils(CSL, assetSerializer);
    testUtils = createCslTestUtils(CSL);
  });

  describe('createCslUtils', () => {
    it('createAssetSerializer', () => {
      const serializer = createAssetSerializer(CSL);
      const tsla = serializer.parseId(TSLA_Asset);
      expect(new TextDecoder().decode(tsla.assetName.name())).toEqual('TSLA');
      expect(tsla.scriptHash.to_bech32('b32_')).toEqual('b32_1vk0jj9lmv0cjkvmxw337u467atqcgkauwd4eczaugzagyghp25l');
      expect(serializer.createId(tsla.scriptHash, tsla.assetName)).toEqual(TSLA_Asset);
    });

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

  describe('coalesceValueQuantities', () => {
    it('coin only', () => {
      const q1: ValueQuantities = { coins: 50n };
      const q2: ValueQuantities = { coins: 100n };
      expect(coalesceValueQuantities(q1, q2)).toEqual({ coins: 150n });
    });
    it('coin and assets', () => {
      const q1: ValueQuantities = {
        coins: 50n,
        assets: {
          [TSLA_Asset]: 50n,
          [PXL_Asset]: 100n
        }
      };
      const q2: ValueQuantities = { coins: 100n };
      const q3: ValueQuantities = {
        coins: 20n,
        assets: {
          [TSLA_Asset]: 20n
        }
      };
      expect(coalesceValueQuantities(q1, q2, q3)).toEqual({
        coins: 170n,
        assets: {
          [TSLA_Asset]: 70n,
          [PXL_Asset]: 100n
        }
      });
    });
    it('computeMinUtxoValue', () => expect(typeof computeMinUtxoValue(100n)).toBe('bigint'));
  });
});
