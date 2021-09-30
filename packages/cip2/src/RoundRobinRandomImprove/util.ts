import { BigIntMath, CSL } from '@cardano-sdk/core';
import { uniq } from 'lodash-es';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { OgmiosValue, valueToValueQuantities } from '../util';

export interface WithValue {
  value: OgmiosValue;
}

export interface UtxoWithValue extends WithValue {
  utxo: CSL.TransactionUnspentOutput;
}

export interface OutputWithValue extends WithValue {
  output: CSL.TransactionOutput;
}

export interface RoundRobinRandomImproveArgs {
  utxosWithValue: UtxoWithValue[];
  outputsWithValue: OutputWithValue[];
  uniqueOutputAssetIDs: string[];
}

export interface UtxoSelection {
  utxoSelected: UtxoWithValue[];
  utxoRemaining: UtxoWithValue[];
}

export const preprocessArgs = (
  availableUtxo: CSL.TransactionUnspentOutput[],
  outputs: CSL.TransactionOutput[]
): RoundRobinRandomImproveArgs => {
  const utxosWithValue = availableUtxo.map((utxo) => ({
    utxo,
    value: valueToValueQuantities(utxo.output().amount())
  }));
  const outputsWithValue = outputs.map((output) => ({
    output,
    value: valueToValueQuantities(output.amount())
  }));
  const uniqueOutputAssetIDs = uniq(
    outputsWithValue.flatMap(({ value: { assets } }) => (assets && Object.keys(assets)) || [])
  );
  return { uniqueOutputAssetIDs, utxosWithValue, outputsWithValue };
};

export const withValuesToValues = (totals: WithValue[]) => totals.map((t) => t.value);
export const assetQuantitySelector =
  (id: string) =>
  (quantities: OgmiosValue[]): bigint =>
    BigIntMath.sum(quantities.map(({ assets }) => assets?.[id] || 0n));
export const assetWithValueQuantitySelector =
  (id: string) =>
  (totals: WithValue[]): bigint =>
    assetQuantitySelector(id)(withValuesToValues(totals));
export const getCoinQuantity = (quantities: OgmiosValue[]): bigint =>
  BigIntMath.sum(quantities.map(({ coins }) => coins));
export const getWithValuesCoinQuantity = (totals: WithValue[]): bigint => getCoinQuantity(withValuesToValues(totals));

export const assertIsCoinBalanceSufficient = (utxoValues: OgmiosValue[], outputValues: OgmiosValue[]) => {
  const utxoCoinTotal = getCoinQuantity(utxoValues);
  const outputsCoinTotal = getCoinQuantity(outputValues);
  if (outputsCoinTotal > utxoCoinTotal) {
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
  uniqueOutputAssetIDs: string[],
  utxoValues: OgmiosValue[],
  outputValues: OgmiosValue[]
): void => {
  for (const assetId of uniqueOutputAssetIDs) {
    const getAssetQuantity = assetQuantitySelector(assetId);
    const utxoTotal = getAssetQuantity(utxoValues);
    const outputsTotal = getAssetQuantity(outputValues);
    if (outputsTotal > utxoTotal) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
  }
  assertIsCoinBalanceSufficient(utxoValues, outputValues);
};
