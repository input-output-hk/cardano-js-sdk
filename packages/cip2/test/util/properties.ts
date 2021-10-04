import { AllAssets, TestUtils } from './util';
import { SelectionResult } from '../../src/types';
import { CSL, cslUtil, Ogmios } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../../src/InputSelectionError';
import fc, { Arbitrary } from 'fast-check';
import { MockSelectionConstraints } from './constraints';

const assertExtraChangeProperties = ({ minimumCoinQuantity }: MockSelectionConstraints, results: SelectionResult) => {
  for (const value of results.selection.change) {
    const { coins, assets } = Ogmios.cslToOgmios.value(value);
    // Min UTxO coin requirement for change
    expect(coins).toBeGreaterThanOrEqual(minimumCoinQuantity);
    // No 0 quantity assets
    if (assets) {
      for (const quantity of Object.values(assets)) {
        expect(quantity).toBeGreaterThan(0n);
      }
    }
    // No empty change bundles.
    expect(coins > 0n || Object.keys(assets || {}).length > 0).toBe(true);
  }
};

export const assertInputSelectionProperties = ({
  utils,
  results,
  outputs,
  utxo,
  constraints
}: {
  utils: TestUtils;
  results: SelectionResult;
  outputs: Set<CSL.TransactionOutput>;
  utxo: Set<CSL.TransactionUnspentOutput>;
  constraints: MockSelectionConstraints;
}) => {
  const vSelected = utils.getTotalInputAmounts(results);
  const vRequested = utils.getTotalOutputAmounts([...outputs]);

  // Coverage of Payments
  expect(vSelected.coins).toBeGreaterThanOrEqual(vRequested.coins);
  for (const assetName of AllAssets) {
    expect(vSelected.assets?.[assetName] || 0n).toBeGreaterThanOrEqual(vRequested.assets?.[assetName] || 0n);
  }

  // Correctness of Change
  const vChange = utils.getTotalChangeAmounts(results);
  const vFee = BigInt(results.selection.fee.to_str());
  expect(vSelected.coins).toEqual(vRequested.coins + vChange.coins + vFee);
  for (const assetName of AllAssets) {
    expect(vSelected.assets?.[assetName] || 0n).toEqual(
      (vRequested.assets?.[assetName] || 0n) + (vChange.assets?.[assetName] || 0n)
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
  outputsAmounts
}: {
  error: InputSelectionError;
  utxoAmounts: Ogmios.util.OgmiosValue[];
  outputsAmounts: Ogmios.util.OgmiosValue[];
  constraints: MockSelectionConstraints;
}) => {
  const utxoTotals = Ogmios.util.coalesceValueQuantities(...utxoAmounts);
  const outputsTotals = Ogmios.util.coalesceValueQuantities(...outputsAmounts);
  switch (error.failure) {
    case InputSelectionFailure.UtxoBalanceInsufficient: {
      const insufficientCoin = utxoTotals.coins < outputsTotals.coins + constraints.minimumCost;
      const insufficientAsset =
        outputsTotals.assets &&
        Object.keys(outputsTotals.assets).some(
          (assetId) => (utxoTotals.assets?.[assetId] || 0n) < outputsTotals.assets![assetId]
        );
      expect(insufficientCoin || insufficientAsset).toBe(true);
      return;
    }
    case InputSelectionFailure.UtxoFullyDepleted: {
      const numUtxoAssets = Object.keys(utxoTotals.assets || {}).length;
      const bundleSizePotentiallyTooLarge = numUtxoAssets > constraints.maxTokenBundleSize;
      const changeMinimumCoinQuantityNotMet =
        utxoTotals.coins - outputsTotals.coins - constraints.minimumCost < constraints.minimumCoinQuantity;
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

/**
 * @returns {Arbitrary} fast-check arbitrary that generates valid sets of UTxO and outputs for input selection.
 */
export const generateSelectionParams = (() => {
  /**
   * Generate random amount of coin and assets.
   */
  const arrayOfCoinAndAssets = () =>
    fc
      .array(
        fc.record<Ogmios.util.OgmiosValue>({
          coins: fc.bigUint(cslUtil.MAX_U64),
          assets: fc.oneof(
            fc
              .set(fc.oneof(...AllAssets.map((asset) => fc.constant(asset))))
              .chain((assets) =>
                fc.tuple(...assets.map((asset) => fc.bigUint(cslUtil.MAX_U64).map((amount) => ({ asset, amount }))))
              )
              .map((assets) =>
                assets.reduce((quantities, { amount, asset }) => {
                  quantities[asset] = amount;
                  return quantities;
                }, {} as Ogmios.util.TokenMap)
              ),
            fc.constant(void 0)
          )
        }),
        { maxLength: 11 }
      )
      .filter((values) => {
        // sum of coin or any asset can't exceed MAX_U64
        const { coins, assets } = Ogmios.util.coalesceValueQuantities(...values);
        return (
          coins <= cslUtil.MAX_U64 &&
          (!assets || Object.values(assets).every((quantity) => quantity <= cslUtil.MAX_U64))
        );
      });

  return (): Arbitrary<{
    utxoAmounts: Ogmios.util.OgmiosValue[];
    outputsAmounts: Ogmios.util.OgmiosValue[];
    constraints: MockSelectionConstraints;
  }> =>
    fc.record({
      utxoAmounts: arrayOfCoinAndAssets(),
      outputsAmounts: arrayOfCoinAndAssets(),
      constraints: fc.record<MockSelectionConstraints>({
        maxTokenBundleSize: fc.nat(AllAssets.length),
        minimumCoinQuantity: fc.oneof(...[0n, 1n, 34_482n * 29n, 9_999_991n].map((n) => fc.constant(n))),
        minimumCost: fc.oneof(...[0n, 1n, 200_000n, 2_000_003n].map((n) => fc.constant(n))),
        selectionLimit: fc.oneof(...[0, 1, 2, 7, 30, Number.MAX_SAFE_INTEGER].map((n) => fc.constant(n)))
      })
    });
})();
