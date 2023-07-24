import { Cardano } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure, splitChange } from '../../src';
import { asAssetId, asPaymentAddress, asTokenMap, getCoinValueForAddress } from '../util';

describe('splitChange', () => {
  it('correctly split pure lovelace change', async () => {
    const changeAddressWithDistribution = new Map([
      [asPaymentAddress('A'), 4],
      [asPaymentAddress('B'), 3],
      [asPaymentAddress('C'), 1]
    ]);

    const change = await splitChange(
      async () => changeAddressWithDistribution,
      100n,
      undefined,
      () => 10n,
      () => false,
      0n
    );

    expect(getCoinValueForAddress('A', change)).toEqual(50n);
    expect(getCoinValueForAddress('B', change)).toEqual(38n);
    expect(getCoinValueForAddress('C', change)).toEqual(12n);

    expect(change).toEqual([
      { address: 'A', value: { coins: 25n } },
      { address: 'B', value: { coins: 19n } },
      { address: 'B', value: { coins: 19n } },
      { address: 'A', value: { coins: 13n } },
      { address: 'A', value: { coins: 12n } },
      { address: 'C', value: { coins: 12n } }
    ]);
  });

  it('pushes the error to the last token', async () => {
    const changeAddressWithDistribution = new Map([
      [asPaymentAddress('A'), 1],
      [asPaymentAddress('B'), 1],
      [asPaymentAddress('C'), 1]
    ]);

    const change = await splitChange(
      async () => changeAddressWithDistribution,
      100n,
      undefined,
      () => 10n,
      () => false,
      0n
    );

    expect(getCoinValueForAddress('A', change)).toEqual(34n);
    expect(getCoinValueForAddress('B', change)).toEqual(34n);
    expect(getCoinValueForAddress('C', change)).toEqual(32n); // Rounding error is pushed to the last entry

    expect(change).toEqual([
      { address: 'A', value: { coins: 17n } },
      { address: 'A', value: { coins: 17n } },
      { address: 'B', value: { coins: 17n } },
      { address: 'B', value: { coins: 17n } },
      { address: 'C', value: { coins: 16n } },
      { address: 'C', value: { coins: 16n } }
    ]);
  });

  it('allocates native assets on the first output', async () => {
    const changeAddressWithDistribution = new Map([
      [asPaymentAddress('A'), 1],
      [asPaymentAddress('B'), 1],
      [asPaymentAddress('C'), 1]
    ]);

    const assets = asTokenMap([
      [asAssetId('0'), 100n],
      [asAssetId('1'), 23n],
      [asAssetId('2'), 1n],
      [asAssetId('3'), 1000n],
      [asAssetId('4'), 1500n],
      [asAssetId('5'), 500n]
    ]);

    const change = await splitChange(
      async () => changeAddressWithDistribution,
      60_000_000n, // 60 ADA in change
      assets,
      () => 10n,
      () => false,
      200_000n
    );

    expect(getCoinValueForAddress('A', change)).toEqual(20_000_000n);
    expect(change[0].value.assets).toEqual(assets);
    expect(getCoinValueForAddress('B', change)).toEqual(20_000_000n);
    expect(getCoinValueForAddress('C', change)).toEqual(20_000_000n);
  });

  it('spills over native assets to other change outputs if they dont fit', async () => {
    const changeAddressWithDistribution = new Map([
      [asPaymentAddress('A'), 1],
      [asPaymentAddress('B'), 1],
      [asPaymentAddress('C'), 1]
    ]);

    const assets = asTokenMap([
      [asAssetId('0'), 100n],
      [asAssetId('1'), 23n],
      [asAssetId('2'), 1n],
      [asAssetId('3'), 1000n],
      [asAssetId('4'), 1500n],
      [asAssetId('5'), 500n]
    ]);

    const change = await splitChange(
      async () => changeAddressWithDistribution,
      60_000_000n, // 60 ADA in change
      assets,
      () => 10n,
      (tokenBundle: Cardano.TokenMap | undefined) => tokenBundle!.size > 4, // Impose an artificial limit of four asset class per output.
      200_000n
    );

    expect(getCoinValueForAddress('A', change)).toEqual(20_000_000n);
    expect(change[0].value.assets).toEqual(
      asTokenMap([
        [asAssetId('2'), 1n],
        [asAssetId('3'), 1000n],
        [asAssetId('4'), 1500n],
        [asAssetId('5'), 500n]
      ])
    );

    expect(getCoinValueForAddress('B', change)).toEqual(20_000_000n);
    expect(change[1].value.assets).toEqual(
      asTokenMap([
        [asAssetId('0'), 100n],
        [asAssetId('1'), 23n]
      ])
    );

    expect(getCoinValueForAddress('C', change)).toEqual(20_000_000n);
    expect(change[2].value.assets).toBeUndefined();
  });

  it('throws InputSelectionError with UtxoFullyDepleted if it cant fit the native assets in the change outputs', async () => {
    const changeAddressWithDistribution = new Map([
      [asPaymentAddress('A'), 1],
      [asPaymentAddress('B'), 1],
      [asPaymentAddress('C'), 1]
    ]);

    const assets = asTokenMap([
      [asAssetId('0'), 100n],
      [asAssetId('1'), 23n],
      [asAssetId('2'), 1n],
      [asAssetId('3'), 1000n],
      [asAssetId('4'), 1500n],
      [asAssetId('5'), 500n]
    ]);

    await expect(
      splitChange(
        async () => changeAddressWithDistribution,
        10_000_000n, // 10 ADA in change
        assets,
        () => 10n,
        (tokenBundle: Cardano.TokenMap | undefined) => tokenBundle!.size > 1, // Impose an artificial limit of one asset class per output.
        2_000_000n
      )
    ).rejects.toThrow(new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted));
  });

  it('throws InputSelectionError with UtxoFullyDepleted if it doesnt have enough lovelace to fulfill minimum coin quantity per output', async () => {
    const changeAddressWithDistribution = new Map([
      [asPaymentAddress('A'), 1],
      [asPaymentAddress('B'), 1],
      [asPaymentAddress('C'), 1]
    ]);

    const assets = asTokenMap([
      [asAssetId('0'), 100n],
      [asAssetId('1'), 23n],
      [asAssetId('2'), 1n],
      [asAssetId('3'), 1000n],
      [asAssetId('4'), 1500n],
      [asAssetId('5'), 500n]
    ]);

    await expect(
      splitChange(
        async () => changeAddressWithDistribution,
        10n,
        assets,
        () => 10n,
        () => false,
        2_000_000n
      )
    ).rejects.toThrow(new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted));
  });
});
