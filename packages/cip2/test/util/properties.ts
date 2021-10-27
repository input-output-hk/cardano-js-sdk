import { AssetId, SelectionConstraints } from '@cardano-sdk/util-dev';
import { CSL, Cardano, cslToCore, cslUtil } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../../src/InputSelectionError';
import { SelectionResult } from '../../src/types';
import fc, { Arbitrary } from 'fast-check';

const assertExtraChangeProperties = (
  { minimumCoinQuantity }: SelectionConstraints.MockSelectionConstraints,
  results: SelectionResult
) => {
  for (const value of results.selection.change) {
    const { coins, assets } = cslToCore.value(value);
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

const totalOutputsValue = (outputs: Set<CSL.TransactionOutput>) =>
  Cardano.util.coalesceValueQuantities([...outputs].map((output) => cslToCore.value(output.amount())));

const totalUtxosValue = (results: SelectionResult) =>
  Cardano.util.coalesceValueQuantities(
    [...results.selection.inputs].map((selectedUtxo) => cslToCore.value(selectedUtxo.output().amount()))
  );

const inputSelectionTotals = ({
  results,
  outputs,
  implicitCoin
}: {
  results: SelectionResult;
  outputs: Set<CSL.TransactionOutput>;
  implicitCoin?: Cardano.ImplicitCoin;
}) => {
  const vSelectedUtxo = totalUtxosValue(results);
  const vSelected = {
    ...vSelectedUtxo,
    coins: vSelectedUtxo.coins + BigInt(implicitCoin?.input || 0)
  };
  const vRequestedOutputs = totalOutputsValue(outputs);
  const vFee = BigInt(results.selection.fee.to_str());
  const vRequested = {
    ...vRequestedOutputs,
    coins: vRequestedOutputs.coins + BigInt(implicitCoin?.deposit || 0) + vFee
  };
  const vChange = Cardano.util.coalesceValueQuantities(
    [...results.selection.change].map((value) => cslToCore.value(value))
  );
  return { vChange, vRequested, vSelected };
};

export const assertInputSelectionProperties = ({
  results,
  outputs,
  utxo,
  constraints,
  implicitCoin
}: {
  results: SelectionResult;
  outputs: Set<CSL.TransactionOutput>;
  utxo: Set<CSL.TransactionUnspentOutput>;
  constraints: SelectionConstraints.MockSelectionConstraints;
  implicitCoin?: Cardano.ImplicitCoin;
}) => {
  const { vSelected, vRequested, vChange } = inputSelectionTotals({ implicitCoin, outputs, results });

  // Coverage of Payments
  expect(vSelected.coins).toBeGreaterThanOrEqual(vRequested.coins);
  for (const assetName of AssetId.All) {
    expect(vSelected.assets?.[assetName] || 0n).toBeGreaterThanOrEqual(vRequested.assets?.[assetName] || 0n);
  }

  // Correctness of Change
  expect(vSelected.coins).toEqual(vRequested.coins + vChange.coins);
  for (const assetName of AssetId.All) {
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
  outputsAmounts,
  implicitCoin
}: {
  error: InputSelectionError;
  utxoAmounts: Cardano.Value[];
  outputsAmounts: Cardano.Value[];
  constraints: SelectionConstraints.MockSelectionConstraints;
  implicitCoin?: Cardano.ImplicitCoin;
}) => {
  const availableQuantities = Cardano.util.coalesceValueQuantities([
    ...utxoAmounts,
    { coins: BigInt(implicitCoin?.input || 0) }
  ]);
  const requestedQuantities = Cardano.util.coalesceValueQuantities([
    ...outputsAmounts,
    { coins: BigInt(implicitCoin?.deposit || 0) + constraints.minimumCost }
  ]);
  switch (error.failure) {
    case InputSelectionFailure.UtxoBalanceInsufficient: {
      const insufficientCoin = availableQuantities.coins < requestedQuantities.coins;
      const insufficientAsset =
        requestedQuantities.assets &&
        Object.keys(requestedQuantities.assets).some(
          (assetId) => (availableQuantities.assets?.[assetId] || 0n) < requestedQuantities.assets![assetId]
        );
      expect(insufficientCoin || insufficientAsset).toBe(true);
      return;
    }
    case InputSelectionFailure.UtxoFullyDepleted: {
      const numUtxoAssets = Object.keys(availableQuantities.assets || {}).length;
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

/**
 * @returns {Arbitrary} fast-check arbitrary that generates valid sets of UTxO and outputs for input selection.
 */
export const generateSelectionParams = (() => {
  /**
   * Generate random amount of coin and assets.
   */
  const arrayOfCoinAndAssets = (implicitCoin = 0n) =>
    fc
      .array(
        fc.record<Cardano.Value>({
          assets: fc.oneof(
            fc
              .set(fc.oneof(...AssetId.All.map((asset) => fc.constant(asset))))
              .chain((assets) =>
                fc.tuple(...assets.map((asset) => fc.bigUint(cslUtil.MAX_U64).map((amount) => ({ amount, asset }))))
              )
              .map((assets) =>
                assets.reduce((quantities, { amount, asset }) => {
                  quantities[asset] = amount;
                  return quantities;
                }, {} as Cardano.TokenMap)
              ),
            fc.constant(void 0)
          ),
          coins: fc.bigUint(cslUtil.MAX_U64 - implicitCoin)
        }),
        { maxLength: 11 }
      )
      .filter((values) => {
        // sum of coin or any asset can't exceed MAX_U64
        const { coins, assets } = Cardano.util.coalesceValueQuantities(values);
        return (
          coins + implicitCoin <= cslUtil.MAX_U64 &&
          (!assets || Object.values(assets).every((quantity) => quantity <= cslUtil.MAX_U64))
        );
      });

  const generateImplicitCoin: Arbitrary<Cardano.ImplicitCoin | undefined> = fc.oneof(
    fc.constant(void 0),
    fc.record({
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
    })
  );

  return (): Arbitrary<{
    utxoAmounts: Cardano.Value[];
    outputsAmounts: Cardano.Value[];
    constraints: SelectionConstraints.MockSelectionConstraints;
    implicitCoin?: Cardano.ImplicitCoin;
  }> =>
    generateImplicitCoin.chain((implicitCoin) =>
      fc.record({
        constraints: fc.record<SelectionConstraints.MockSelectionConstraints>({
          maxTokenBundleSize: fc.nat(AssetId.All.length),
          minimumCoinQuantity: fc.oneof(...[0n, 1n, 34_482n * 29n, 9_999_991n].map((n) => fc.constant(n))),
          minimumCost: fc.oneof(...[0n, 1n, 200_000n, 2_000_003n].map((n) => fc.constant(n))),
          selectionLimit: fc.oneof(...[0, 1, 2, 7, 30, Number.MAX_SAFE_INTEGER].map((n) => fc.constant(n)))
        }),
        implicitCoin: fc.constant(implicitCoin),
        outputsAmounts: arrayOfCoinAndAssets(implicitCoin?.deposit),
        utxoAmounts: arrayOfCoinAndAssets(implicitCoin?.input)
      })
    );
})();
