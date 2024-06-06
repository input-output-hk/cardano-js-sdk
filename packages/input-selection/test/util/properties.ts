import { Asset, coalesceValueQuantities } from '@cardano-sdk/core';
import { AssetId } from '@cardano-sdk/util-dev';
import { InputSelectionFailure } from '../../src/InputSelectionError.js';
import { mintToImplicitTokens } from '../../src/util.js';
import fc from 'fast-check';
import type * as SelectionConstraints from './selectionConstraints.js';
import type { Arbitrary } from 'fast-check';
import type { Cardano } from '@cardano-sdk/core';
import type { ImplicitValue, SelectionResult } from '../../src/types.js';
import type { InputSelectionError } from '../../src/InputSelectionError.js';

export const MAX_U64 = 18_446_744_073_709_551_615n;
export const MIN_I64 = -9_223_372_036_854_775_808n;
export const MAX_I64 = 9_223_372_036_854_775_807n;

const assertExtraChangeProperties = (
  { minimumCoinQuantity }: SelectionConstraints.MockSelectionConstraints,
  results: SelectionResult
) => {
  for (const {
    value: { coins, assets }
  } of results.selection.change) {
    // Min UTxO coin requirement for change
    expect(coins).toBeGreaterThanOrEqual(minimumCoinQuantity);
    // No 0 quantity assets
    if (assets) {
      for (const quantity of assets.values()) {
        expect(quantity).toBeGreaterThan(0n);
      }
    }
    // No empty change bundles.
    expect(coins > 0n || (assets?.size || 0) > 0).toBe(true);
  }
};

const totalOutputsValue = (outputs: Set<Cardano.TxOut>) =>
  coalesceValueQuantities([...outputs].map(({ value }) => value));

const totalUtxosValue = (results: SelectionResult) =>
  coalesceValueQuantities([...results.selection.inputs].map(([_, { value }]) => value));

const inputSelectionTotals = ({
  results,
  outputs,
  implicitValue
}: {
  results: SelectionResult;
  outputs: Set<Cardano.TxOut>;
  implicitValue?: ImplicitValue;
}) => {
  const { implicitTokensInput, implicitTokensSpend } = mintToImplicitTokens(implicitValue?.mint);
  const vSelectedUtxo = totalUtxosValue(results);
  const vSelected = {
    assets: Asset.util.coalesceTokenMaps([vSelectedUtxo.assets, implicitTokensInput]),
    coins: vSelectedUtxo.coins + BigInt(implicitValue?.coin?.input || 0)
  };
  const vRequestedOutputs = totalOutputsValue(outputs);
  const vFee = results.selection.fee;
  const vRequested = {
    assets: Asset.util.coalesceTokenMaps([vRequestedOutputs.assets, implicitTokensSpend]),
    coins: vRequestedOutputs.coins + BigInt(implicitValue?.coin?.deposit || 0) + vFee
  };
  const vChange = coalesceValueQuantities(results.selection.change.map((txOut) => txOut.value));
  return { vChange, vRequested, vSelected };
};

export const assertInputSelectionProperties = ({
  results,
  outputs,
  utxo,
  constraints,
  implicitValue
}: {
  results: SelectionResult;
  outputs: Set<Cardano.TxOut>;
  utxo: Set<Cardano.Utxo>;
  constraints: SelectionConstraints.MockSelectionConstraints;
  implicitValue?: ImplicitValue;
}) => {
  const { vSelected, vRequested, vChange } = inputSelectionTotals({ implicitValue, outputs, results });

  // Coverage of Payments
  expect(vSelected.coins).toBeGreaterThanOrEqual(vRequested.coins);
  for (const assetName of AssetId.All) {
    expect(vSelected.assets?.get(assetName) || 0n).toBeGreaterThanOrEqual(vRequested.assets?.get(assetName) || 0n);
  }

  // Correctness of Change
  expect(vSelected.coins).toEqual(vRequested.coins + vChange.coins);
  for (const assetName of AssetId.All) {
    expect(vSelected.assets?.get(assetName) || 0n).toEqual(
      (vRequested.assets?.get(assetName) || 0n) + (vChange.assets?.get(assetName) || 0n)
    );
  }

  // Conservation of UTxO
  for (const utxoEntry of utxo) {
    const isInInputSelectionInputsSet = results.selection.inputs.has(utxoEntry);
    const isInRemainingUtxoSet = results.remainingUTxO.has(utxoEntry);
    expect(isInInputSelectionInputsSet || isInRemainingUtxoSet).toBe(true);
    expect(isInInputSelectionInputsSet).not.toEqual(isInRemainingUtxoSet);
  }

  // Conservation of Outputs
  // If this is used to test other algorithms refactor this
  // to clone outputs before and do deepEquals to assert it wasn't mutated
  expect(results.selection.outputs).toBe(outputs);

  assertExtraChangeProperties(constraints, results);
};

export const assertFailureProperties = ({
  error,
  constraints,
  utxoAmounts,
  outputsAmounts,
  implicitValue
}: {
  error: InputSelectionError;
  utxoAmounts: Cardano.Value[];
  outputsAmounts: Cardano.Value[];
  constraints: SelectionConstraints.MockSelectionConstraints;
  implicitValue?: ImplicitValue;
}) => {
  const { implicitTokensInput, implicitTokensSpend } = mintToImplicitTokens(implicitValue?.mint);
  const availableQuantities = coalesceValueQuantities([
    ...utxoAmounts,
    { assets: implicitTokensInput, coins: BigInt(implicitValue?.coin?.input || 0) }
  ]);
  const maxPossibleFee = constraints.minimumCostCoefficient * BigInt(utxoAmounts.length);
  const requestedQuantities = coalesceValueQuantities([
    ...outputsAmounts,
    { assets: implicitTokensSpend, coins: BigInt(implicitValue?.coin?.deposit || 0) + maxPossibleFee }
  ]);
  switch (error.failure) {
    case InputSelectionFailure.UtxoBalanceInsufficient: {
      if (utxoAmounts.length === 0) return; // must select at least 1 utxo
      const insufficientCoin = availableQuantities.coins < requestedQuantities.coins;
      const insufficientAsset =
        requestedQuantities.assets &&
        [...requestedQuantities.assets.keys()].some(
          (assetId) => (availableQuantities.assets?.get(assetId) || 0n) < requestedQuantities.assets!.get(assetId)!
        );
      expect(insufficientCoin || insufficientAsset).toBe(true);
      return;
    }
    case InputSelectionFailure.UtxoFullyDepleted: {
      const numUtxoAssets = availableQuantities.assets?.size || 0;
      const bundleSizePotentiallyTooLarge = numUtxoAssets > constraints.maxTokenBundleSize;
      const changeMinimumCoinQuantityNotMet =
        availableQuantities.coins - requestedQuantities.coins < constraints.minimumCoinQuantity;
      expect(bundleSizePotentiallyTooLarge || changeMinimumCoinQuantityNotMet).toBe(true);
      return;
    }
    case InputSelectionFailure.MaximumInputCountExceeded: {
      // Not a great test, but an algorithm might select all utxo.
      // Complemented with example-based tests.
      expect(utxoAmounts.length).toBeGreaterThan(constraints.selectionLimit);
      return;
    }
  }
  throw error;
};

const generateTokenMap = (minQuantity: bigint, maxQuantity: bigint) =>
  fc
    .uniqueArray(fc.oneof(...AssetId.All.map((asset) => fc.constant(asset))), { comparator: 'IsStrictlyEqual' })
    .chain((assets) =>
      fc.tuple(...assets.map((asset) => fc.bigInt(minQuantity, maxQuantity).map((amount) => ({ amount, asset }))))
    )
    .map((assets) => new Map<Cardano.AssetId, Cardano.Lovelace>(assets.map(({ amount, asset }) => [asset, amount])));

/**
 * @returns {Arbitrary} fast-check arbitrary that generates valid sets of UTxO and outputs for input selection.
 */
export const generateSelectionParams = (() => {
  /** Generate random amount of coin and assets. */
  const arrayOfCoinAndAssets = (implicitCoin = 0n) =>
    fc
      .array(
        fc.record<Cardano.Value>({
          assets: fc.oneof(generateTokenMap(1n, MAX_U64), fc.constant(void 0)),
          coins: fc.bigInt(1n, MAX_U64 - implicitCoin)
        }),
        { maxLength: 11 }
      )
      .filter((values) => {
        // sum of coin or any asset can't exceed MAX_U64
        const { coins, assets } = coalesceValueQuantities(values);
        return (
          coins + implicitCoin <= MAX_U64 && (!assets || [...assets.values()].every((quantity) => quantity <= MAX_U64))
        );
      });

  const generateImplicitCoin: Arbitrary<Cardano.util.ImplicitCoin> = fc.record({
    deposit: fc.oneof(
      fc.constant(void 0),
      fc
        .tuple(fc.bigUint(2n), fc.bigUint(2n))
        .map(([numKeyDeposits, numPoolDeposits]) => numKeyDeposits * 2_000_000n + numPoolDeposits * 500_000_000n)
    ),
    input: fc.oneof(
      fc.constant(void 0),
      fc
        .tuple(
          fc.bigUint(2n),
          fc.bigUint(2n),
          fc.oneof(fc.constant(0n), fc.constant(1n), fc.constant(200_000n), fc.constant(2_000_003n))
        )
        .map(
          ([numKeyDeposits, numPoolDeposits, withdrawals]) =>
            numKeyDeposits * 2_000_000n + numPoolDeposits * 500_000_000n + withdrawals
        )
    )
  });

  const generateImplicitValue: Arbitrary<ImplicitValue | undefined> = fc.oneof(
    fc.constant(void 0),
    fc.record<ImplicitValue>({
      coin: fc.oneof(fc.constant(void 0), generateImplicitCoin),
      mint: fc.oneof(fc.constant(void 0), generateTokenMap(MIN_I64, MAX_I64))
    })
  );

  return (): Arbitrary<{
    utxoAmounts: Cardano.Value[];
    outputsAmounts: Cardano.Value[];
    constraints: SelectionConstraints.MockSelectionConstraints;
    implicitValue?: ImplicitValue;
  }> =>
    generateImplicitValue.chain((implicitValue) =>
      fc.record({
        constraints: fc.record<SelectionConstraints.MockSelectionConstraints>({
          maxTokenBundleSize: fc.nat(AssetId.All.length),
          minimumCoinQuantity: fc.oneof(...[0n, 1n, 34_482n * 29n, 9_999_991n].map((n) => fc.constant(n))),
          minimumCostCoefficient: fc.oneof(...[0n, 1n, 200_000n, 2_000_003n].map((n) => fc.constant(n))),
          selectionLimit: fc.oneof(...[0, 1, 2, 7, 30, Number.MAX_SAFE_INTEGER].map((n) => fc.constant(n)))
        }),
        implicitValue: fc.constant(implicitValue),
        outputsAmounts: arrayOfCoinAndAssets(implicitValue?.coin?.deposit),
        utxoAmounts: arrayOfCoinAndAssets(implicitValue?.coin?.input)
      })
    );
})();
