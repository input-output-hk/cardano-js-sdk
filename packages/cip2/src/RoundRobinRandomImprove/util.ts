import { BigIntMath, CSL, Cardano, cslToCore } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { uniq } from 'lodash-es';

export interface WithValue {
  value: Cardano.Value;
}

export interface UtxoWithValue extends WithValue {
  utxo: CSL.TransactionUnspentOutput;
}

export interface OutputWithValue extends WithValue {
  output: CSL.TransactionOutput;
}

export interface ImplicitCoinBigint {
  input: bigint;
  deposit: bigint;
}

export interface RoundRobinRandomImproveArgs {
  utxosWithValue: UtxoWithValue[];
  outputsWithValue: OutputWithValue[];
  uniqueOutputAssetIDs: Cardano.AssetId[];
  implicitCoin: ImplicitCoinBigint;
}

export interface UtxoSelection {
  utxoSelected: UtxoWithValue[];
  utxoRemaining: UtxoWithValue[];
}

const noImplicitCoin = {
  deposit: 0n,
  input: 0n
};

export const preprocessArgs = (
  availableUtxo: Set<CSL.TransactionUnspentOutput>,
  outputs: Set<CSL.TransactionOutput>,
  partialImplicitCoin: Cardano.ImplicitCoin = noImplicitCoin
): RoundRobinRandomImproveArgs => {
  const utxosWithValue = [...availableUtxo].map((utxo) => ({
    utxo,
    value: cslToCore.value(utxo.output().amount())
  }));
  const outputsWithValue = [...outputs].map((output) => ({
    output,
    value: cslToCore.value(output.amount())
  }));
  const uniqueOutputAssetIDs = uniq(outputsWithValue.flatMap(({ value: { assets } }) => [...(assets?.keys() || [])]));
  const implicitCoin: ImplicitCoinBigint = {
    deposit: partialImplicitCoin.deposit || 0n,
    input: partialImplicitCoin.input || 0n
  };
  return { implicitCoin, outputsWithValue, uniqueOutputAssetIDs, utxosWithValue };
};

export const withValuesToValues = (totals: WithValue[]) => totals.map((t) => t.value);
export const assetQuantitySelector =
  (id: Cardano.AssetId) =>
  (quantities: Cardano.Value[]): bigint =>
    BigIntMath.sum(quantities.map(({ assets }) => assets?.get(id) || 0n));
export const assetWithValueQuantitySelector =
  (id: Cardano.AssetId) =>
  (totals: WithValue[]): bigint =>
    assetQuantitySelector(id)(withValuesToValues(totals));
export const getCoinQuantity = (quantities: Cardano.Value[]): bigint =>
  BigIntMath.sum(quantities.map(({ coins }) => coins));
export const getWithValuesCoinQuantity = (totals: WithValue[]): bigint => getCoinQuantity(withValuesToValues(totals));

export const assertIsCoinBalanceSufficient = (
  utxoValues: Cardano.Value[],
  outputValues: Cardano.Value[],
  implicitCoin: ImplicitCoinBigint
) => {
  const utxoCoinTotal = getCoinQuantity(utxoValues);
  const outputsCoinTotal = getCoinQuantity(outputValues);
  if (outputsCoinTotal + implicitCoin.deposit > utxoCoinTotal + implicitCoin.input) {
    throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
  }
};

/**
 * Asserts that available balance of coin and assets
 * is sufficient to cover output quantities.
 *
 * @throws InputSelectionError { UtxoBalanceInsufficient }
 */
export const assertIsBalanceSufficient = (
  uniqueOutputAssetIDs: Cardano.AssetId[],
  utxoValues: Cardano.Value[],
  outputValues: Cardano.Value[],
  implicitCoin: ImplicitCoinBigint
): void => {
  if (utxoValues.length === 0) {
    throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
  }
  for (const assetId of uniqueOutputAssetIDs) {
    const getAssetQuantity = assetQuantitySelector(assetId);
    const utxoTotal = getAssetQuantity(utxoValues);
    const outputsTotal = getAssetQuantity(outputValues);
    if (outputsTotal > utxoTotal) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
  }
  assertIsCoinBalanceSufficient(utxoValues, outputValues, implicitCoin);
};
