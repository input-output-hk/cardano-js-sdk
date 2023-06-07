import { Cardano } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure, splitChange } from '../../src';
import { asAssetId, asPaymentAddress, asTokenMap } from '../util';

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
      2_000_000n
    );

    expect(change.length).toEqual(3);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(50n);
    expect(change[1].address).toEqual(asPaymentAddress('B'));
    expect(change[1].value.coins).toEqual(38n);
    expect(change[2].address).toEqual(asPaymentAddress('C'));
    expect(change[2].value.coins).toEqual(12n);
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
      2_000_000n
    );

    expect(change.length).toEqual(3);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(34n);
    expect(change[1].address).toEqual(asPaymentAddress('B'));
    expect(change[1].value.coins).toEqual(34n);
    expect(change[2].address).toEqual(asPaymentAddress('C'));
    expect(change[2].value.coins).toEqual(32n); // Rounding error is pushed to the last entry
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
      10_000_000n, // 10 ADA in change
      assets,
      () => 10n,
      () => false,
      2_000_000n
    );

    expect(change.length).toEqual(3);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(3_333_334n);
    expect(change[0].value.assets).toEqual(assets);
    expect(change[1].address).toEqual(asPaymentAddress('B'));
    expect(change[1].value.coins).toEqual(3_333_334n);
    expect(change[1].value.assets).toBeUndefined();
    expect(change[2].address).toEqual(asPaymentAddress('C'));
    expect(change[2].value.coins).toEqual(3_333_332n);
    expect(change[2].value.assets).toBeUndefined();
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
      10_000_000n, // 10 ADA in change
      assets,
      () => 10n,
      (tokenBundle: Cardano.TokenMap | undefined) => tokenBundle!.size > 4, // Impose an artificial limit of four asset class per output.
      2_000_000n
    );

    expect(change.length).toEqual(3);
    expect(change[0].address).toEqual(asPaymentAddress('A'));
    expect(change[0].value.coins).toEqual(3_333_334n);
    expect(change[0].value.assets).toEqual(
      asTokenMap([
        [asAssetId('2'), 1n],
        [asAssetId('3'), 1000n],
        [asAssetId('4'), 1500n],
        [asAssetId('5'), 500n]
      ])
    );
    expect(change[1].address).toEqual(asPaymentAddress('B'));
    expect(change[1].value.coins).toEqual(3_333_334n);
    expect(change[1].value.assets).toEqual(
      asTokenMap([
        [asAssetId('0'), 100n],
        [asAssetId('1'), 23n]
      ])
    );
    expect(change[2].address).toEqual(asPaymentAddress('C'));
    expect(change[2].value.coins).toEqual(3_333_332n);
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
