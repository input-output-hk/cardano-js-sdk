import { Cardano } from '@cardano-sdk/core';
import { coalesceChangeBundlesForMinCoinRequirement } from '../src/change';

const TOKEN1_ASSET_ID = Cardano.AssetId('5c677ba4dd295d9286e0e22786fea9ed735a6ae9c07e7a45ae4d95c84249530000');
const TOKEN2_ASSET_ID = Cardano.AssetId('5c677ba4dd295d9286e0e22786fea9ed735a6ae9c07e7a45ae4d95c84249530001');
const TOKEN3_ASSET_ID = Cardano.AssetId('5c677ba4dd295d9286e0e22786fea9ed735a6ae9c07e7a45ae4d95c84249530002');

const MIN_ADA_COIN_VAL = 5_000_000n;
const computeMinimumCoinQuantity = (utxo: Cardano.TxOut): bigint =>
  MIN_ADA_COIN_VAL + (utxo.value.assets ? BigInt(utxo.value.assets.size) : 0n) * 5_000_000n;

describe('coalesceChangeBundlesForMinCoinRequirement', () => {
  it('given empty change bundle list, returns the empty list', async () => {
    const changeBundles: Cardano.Value[] = [];
    const result = coalesceChangeBundlesForMinCoinRequirement(changeBundles, computeMinimumCoinQuantity);

    expect(result).toBeDefined();
    expect(result?.length).toBe(0);
  });

  it('when given 3 bundles with valid min ADA coin, return the three original bundles', async () => {
    const changeBundles: Cardano.Value[] = [{ coins: 5_000_000n }, { coins: 5_000_000n }, { coins: 5_000_000n }];
    const result = coalesceChangeBundlesForMinCoinRequirement(changeBundles, computeMinimumCoinQuantity);

    expect(result).toBeDefined();
    expect(result?.length).toBe(3);

    expect(result![0].coins).toBe(MIN_ADA_COIN_VAL);
    expect(result![1].coins).toBe(MIN_ADA_COIN_VAL);
    expect(result![2].coins).toBe(MIN_ADA_COIN_VAL);
  });

  it('when the last bundle has less than min ADA coin, coalesce it with the second last', async () => {
    const changeBundles: Cardano.Value[] = [{ coins: 5_000_000n }, { coins: 5_000_000n }, { coins: 4_000_000n }];
    const result = coalesceChangeBundlesForMinCoinRequirement(changeBundles, computeMinimumCoinQuantity);

    expect(result).toBeDefined();
    expect(result?.length).toBe(2);

    expect(result![0].coins).toBe(9_000_000n);
    expect(result![1].coins).toBe(5_000_000n);
  });

  it('when the middle bundle has less than min ADA coin, coalesce it with the last', async () => {
    const changeBundles: Cardano.Value[] = [
      { coins: 10_000_000n },
      { assets: new Map([[TOKEN1_ASSET_ID, 2333n]]), coins: 7_000_000n },
      { coins: 5_000_000n }
    ];

    const result = coalesceChangeBundlesForMinCoinRequirement(changeBundles, computeMinimumCoinQuantity);

    expect(result).toBeDefined();
    expect(result?.length).toBe(2);

    expect(result![0].coins).toBe(12_000_000n);
    expect(result![0].assets!.get(TOKEN1_ASSET_ID)).toBe(2333n);
    expect(result![1].coins).toBe(10_000_000n);
  });

  it('when the first bundle has less than min ADA coin, coalesce it with the last', async () => {
    const changeBundles: Cardano.Value[] = [
      { assets: new Map([[TOKEN1_ASSET_ID, 2333n]]), coins: 7_000_000n },
      { coins: 5_000_000n },
      { coins: 5_000_000n }
    ];

    const result = coalesceChangeBundlesForMinCoinRequirement(changeBundles, computeMinimumCoinQuantity);

    expect(result).toBeDefined();
    expect(result?.length).toBe(2);

    expect(result![0].coins).toBe(12_000_000n);
    expect(result![0].assets!.get(TOKEN1_ASSET_ID)).toBe(2333n);
    expect(result![1].coins).toBe(5_000_000n);
  });

  it('when the three bundle have less than min ADA coin, coalesce them together', async () => {
    const changeBundles: Cardano.Value[] = [
      { assets: new Map([[TOKEN1_ASSET_ID, 2333n]]), coins: 7_000_000n },
      { assets: new Map([[TOKEN1_ASSET_ID, 2333n]]), coins: 7_000_000n },
      { assets: new Map([[TOKEN1_ASSET_ID, 2333n]]), coins: 7_000_000n }
    ];

    const result = coalesceChangeBundlesForMinCoinRequirement(changeBundles, computeMinimumCoinQuantity);

    expect(result).toBeDefined();
    expect(result?.length).toBe(1);

    expect(result![0].coins).toBe(21_000_000n);
    expect(result![0].assets!.get(TOKEN1_ASSET_ID)).toBe(6999n);
  });

  it('when coalescing the three bundles do not reach the min ADA coin return undefined', async () => {
    const changeBundles: Cardano.Value[] = [
      { assets: new Map([[TOKEN1_ASSET_ID, 2333n]]), coins: 2_000_000n },
      { assets: new Map([[TOKEN2_ASSET_ID, 2333n]]), coins: 2_000_000n },
      { assets: new Map([[TOKEN3_ASSET_ID, 2333n]]), coins: 2_000_000n }
    ];

    const result = coalesceChangeBundlesForMinCoinRequirement(changeBundles, computeMinimumCoinQuantity);

    expect(result).toBeUndefined();
  });
});
