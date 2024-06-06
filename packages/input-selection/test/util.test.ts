import {
  addTokenMaps,
  hasNegativeAssetValue,
  isValidValue,
  sortByCoins,
  stubMaxSizeAddress,
  subtractTokenMaps
} from '../src/util.js';
import { asAssetId, asTokenMap } from './util/index.js';
import type { Cardano } from '@cardano-sdk/core';

describe('sortByCoins', () => {
  it('can sort TxOut by coin value in descending order', async () => {
    const utxoSet = [
      {
        address: stubMaxSizeAddress,
        value: {
          coins: 2n
        }
      },
      {
        address: stubMaxSizeAddress,
        value: {
          coins: 0n
        }
      },
      {
        address: stubMaxSizeAddress,
        value: {
          coins: 120n
        }
      },
      {
        address: stubMaxSizeAddress,
        value: {
          coins: 10n
        }
      }
    ];

    utxoSet.sort(sortByCoins);

    expect(utxoSet[0].value.coins).toBe(120n);
    expect(utxoSet[1].value.coins).toBe(10n);
    expect(utxoSet[2].value.coins).toBe(2n);
    expect(utxoSet[3].value.coins).toBe(0n);
  });
});

describe('subtractTokenMaps', () => {
  it('returns an empty token map when the two arguments are empty maps', async () => {
    const lhs = new Map<Cardano.AssetId, bigint>();
    const rhs = new Map<Cardano.AssetId, bigint>();

    const result = subtractTokenMaps(lhs, rhs);

    expect(result).toEqual(new Map<Cardano.AssetId, bigint>());
  });

  it('returns a negative value when an entry is missing in the lhs but present in the rhs', async () => {
    const lhs = new Map<Cardano.AssetId, bigint>();
    const rhs = new Map<Cardano.AssetId, bigint>();

    rhs.set(asAssetId('0'), 100n);
    rhs.set(asAssetId('1'), 23n);
    rhs.set(asAssetId('2'), 1n);

    // Value present in both sides should be subtracted.
    // If the result of the subtraction is 0, the value should not be present
    // If it is different from 0, the result of the subtraction should be present.
    rhs.set(asAssetId('4'), 1000n);
    lhs.set(asAssetId('4'), 1000n);
    // Should be present as -500n
    rhs.set(asAssetId('5'), 1000n);
    lhs.set(asAssetId('5'), 500n);
    // Should be present as 500n
    rhs.set(asAssetId('6'), 500n);
    lhs.set(asAssetId('6'), 1000n);

    const result = subtractTokenMaps(lhs, rhs);

    expect(result).toEqual(
      asTokenMap([
        [asAssetId('0'), -100n],
        [asAssetId('1'), -23n],
        [asAssetId('2'), -1n],
        [asAssetId('5'), -500n],
        [asAssetId('6'), 500n]
      ])
    );
  });

  it('returns a positive value when an entry is missing in the rhs but present in the lhs', async () => {
    const lhs = new Map<Cardano.AssetId, bigint>();
    const rhs = new Map<Cardano.AssetId, bigint>();

    lhs.set(asAssetId('0'), 100n);
    lhs.set(asAssetId('1'), 23n);
    lhs.set(asAssetId('2'), 1n);
    rhs.set(asAssetId('4'), 1000n);
    lhs.set(asAssetId('4'), 1000n);
    rhs.set(asAssetId('5'), 1000n);
    lhs.set(asAssetId('5'), 500n);
    rhs.set(asAssetId('6'), 500n);
    lhs.set(asAssetId('6'), 1000n);

    const result = subtractTokenMaps(lhs, rhs);

    expect(result).toEqual(
      asTokenMap([
        [asAssetId('0'), 100n],
        [asAssetId('1'), 23n],
        [asAssetId('2'), 1n],
        [asAssetId('5'), -500n],
        [asAssetId('6'), 500n]
      ])
    );
  });

  it('returns the correct result when there are values missing in both sides of the subtraction', async () => {
    const lhs = new Map<Cardano.AssetId, bigint>();
    const rhs = new Map<Cardano.AssetId, bigint>();

    lhs.set(asAssetId('0'), 100n);
    lhs.set(asAssetId('1'), 23n);
    lhs.set(asAssetId('2'), 1n);
    lhs.set(asAssetId('3'), 1500n);
    rhs.set(asAssetId('4'), 2500n);

    const result = subtractTokenMaps(lhs, rhs);

    expect(result).toEqual(
      asTokenMap([
        [asAssetId('0'), 100n],
        [asAssetId('1'), 23n],
        [asAssetId('2'), 1n],
        [asAssetId('3'), 1500n],
        [asAssetId('4'), -2500n]
      ])
    );
  });

  it('returns the lhs if rhs is undefined', async () => {
    const lhs = new Map<Cardano.AssetId, bigint>();
    const rhs = undefined;

    lhs.set(asAssetId('0'), 100n);
    lhs.set(asAssetId('1'), 23n);
    lhs.set(asAssetId('2'), 1n);
    lhs.set(asAssetId('3'), 1500n);

    const result = subtractTokenMaps(lhs, rhs);

    expect(result).toEqual(lhs);
  });

  it('returns the rhs with inverted signs if lhs is undefined', async () => {
    const rhs = new Map<Cardano.AssetId, bigint>();
    const lhs = undefined;

    rhs.set(asAssetId('0'), 100n);
    rhs.set(asAssetId('1'), -23n);
    rhs.set(asAssetId('2'), 1n);
    rhs.set(asAssetId('3'), 1500n);

    const result = subtractTokenMaps(lhs, rhs);

    expect(result).toEqual(
      asTokenMap([
        [asAssetId('0'), -100n],
        [asAssetId('1'), 23n],
        [asAssetId('2'), -1n],
        [asAssetId('3'), -1500n]
      ])
    );
  });
});

describe('addTokenMaps', () => {
  it('returns an empty token map when the two arguments are empty maps', async () => {
    const lhs = new Map<Cardano.AssetId, bigint>();
    const rhs = new Map<Cardano.AssetId, bigint>();

    const result = addTokenMaps(lhs, rhs);

    expect(result).toEqual(new Map<Cardano.AssetId, bigint>());
  });

  it('returns the aggregate of both maps, if the asset is in both maps adds them together', async () => {
    const lhs = new Map<Cardano.AssetId, bigint>();
    const rhs = new Map<Cardano.AssetId, bigint>();

    rhs.set(asAssetId('0'), 100n);
    rhs.set(asAssetId('1'), 23n);
    rhs.set(asAssetId('2'), 1n);

    rhs.set(asAssetId('3'), 1000n);
    // Should be present as 1500n
    rhs.set(asAssetId('4'), 1000n);
    lhs.set(asAssetId('4'), 500n);
    // Should be present as 500n
    lhs.set(asAssetId('5'), 500n);

    const result = addTokenMaps(lhs, rhs);

    expect(result).toEqual(
      asTokenMap([
        [asAssetId('0'), 100n],
        [asAssetId('1'), 23n],
        [asAssetId('2'), 1n],
        [asAssetId('3'), 1000n],
        [asAssetId('4'), 1500n],
        [asAssetId('5'), 500n]
      ])
    );
  });

  it('returns the lhs if rhs is undefined', async () => {
    const lhs = new Map<Cardano.AssetId, bigint>();
    const rhs = undefined;

    lhs.set(asAssetId('0'), 100n);
    lhs.set(asAssetId('1'), 23n);
    lhs.set(asAssetId('2'), 1n);
    lhs.set(asAssetId('3'), 1500n);

    const result = addTokenMaps(lhs, rhs);

    expect(result).toEqual(lhs);
  });

  it('returns the rhs if lhs is undefined', async () => {
    const rhs = new Map<Cardano.AssetId, bigint>();
    const lhs = undefined;

    rhs.set(asAssetId('0'), 100n);
    rhs.set(asAssetId('1'), -23n);
    rhs.set(asAssetId('2'), 1n);
    rhs.set(asAssetId('3'), 1500n);

    const result = addTokenMaps(lhs, rhs);

    expect(result).toEqual(rhs);
  });
});

describe('hasNegativeAssetValue', () => {
  it('returns true when the token map has an entry with negative value', async () => {
    const map = new Map<Cardano.AssetId, bigint>();
    map.set(asAssetId('0'), 100n);
    map.set(asAssetId('1'), 23n);
    map.set(asAssetId('2'), -1n);
    map.set(asAssetId('3'), 1500n);
    map.set(asAssetId('4'), 2500n);

    expect(hasNegativeAssetValue(map)).toBeTruthy();
  });

  it('returns false when the token map has no entries with negative value', async () => {
    const map = new Map<Cardano.AssetId, bigint>();
    map.set(asAssetId('0'), 100n);
    map.set(asAssetId('1'), 23n);
    map.set(asAssetId('2'), 1n);
    map.set(asAssetId('3'), 1500n);
    map.set(asAssetId('4'), 2500n);

    expect(hasNegativeAssetValue(map)).toBeFalsy();
  });
});

describe('isValidValue', () => {
  it('returns true when both coins is greater than computeMinimumCoinQuantity and assets doesnt exceeds token bundle size Limit', async () => {
    const value = {
      assets: asTokenMap([[asAssetId('0'), 100n]]),
      coins: 100n
    };

    expect(
      isValidValue(
        value,
        () => 99n,
        () => false,
        0n
      )
    ).toBeTruthy();
  });

  it('returns false if value coins is lesser than computeMinimumCoinQuantity', async () => {
    const value = {
      assets: asTokenMap([[asAssetId('0'), 100n]]),
      coins: 100n
    };

    expect(
      isValidValue(
        value,
        () => 101n,
        () => false,
        0n
      )
    ).toBeFalsy();
  });

  it('returns false if assets exceeds token bundle size Limit', async () => {
    const value = {
      assets: asTokenMap([[asAssetId('0'), 100n]]),
      coins: 100n
    };

    expect(
      isValidValue(
        value,
        () => 10n,
        () => true,
        0n
      )
    ).toBeFalsy();
  });
});
