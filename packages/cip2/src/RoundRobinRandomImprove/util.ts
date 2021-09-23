import { BigIntMath } from '@cardano-sdk/core';
import { CSL } from '@cardano-sdk/cardano-serialization-lib';
import { uniq } from 'lodash-es';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { ValueQuantities, valueToValueQuantities } from '../util';

export interface Totals {
  totals: ValueQuantities;
}

export interface UtxoWithTotals extends Totals {
  utxo: CSL.TransactionUnspentOutput;
}

export interface OutputWithTotals extends Totals {
  output: CSL.TransactionOutput;
}

export interface RoundRobinRandomImproveArgs {
  utxoWithTotals: UtxoWithTotals[];
  outputsWithTotals: OutputWithTotals[];
  uniqueOutputAssetIDs: string[];
}

export interface UtxoSelection {
  utxoSelected: UtxoWithTotals[];
  utxoRemaining: UtxoWithTotals[];
}

export const preprocessArgs = (
  availableUtxo: CSL.TransactionUnspentOutput[],
  outputs: CSL.TransactionOutput[]
): RoundRobinRandomImproveArgs => {
  const utxoWithTotals = availableUtxo.map((utxo) => ({
    utxo,
    totals: valueToValueQuantities(utxo.output().amount())
  }));
  const outputsWithTotals = outputs.map((output) => ({
    output,
    totals: valueToValueQuantities(output.amount())
  }));
  const uniqueOutputAssetIDs = uniq(
    outputsWithTotals.flatMap(({ totals: { assets } }) => (assets && Object.keys(assets)) || [])
  );
  return { uniqueOutputAssetIDs, utxoWithTotals, outputsWithTotals };
};

export const assetQuantitySelector =
  (id: string) =>
  (totals: Totals[]): bigint =>
    BigIntMath.sum(totals.map(({ totals: { assets } }) => assets?.[id] || 0n));
export const getCoinQuantity = (totals: Totals[]): bigint =>
  BigIntMath.sum(totals.map(({ totals: { coins } }) => coins));

/**
 * Asserts that available balance of coin and assets
 * is sufficient to cover output quantities.
 *
 * @throws InputSelectionError { UtxoBalanceInsufficient }
 */
export const assertIsBalanceSufficient = (
  uniqueOutputAssetIDs: string[],
  utxoWithTotals: UtxoWithTotals[],
  outputsWithTotals: OutputWithTotals[]
): void => {
  for (const assetId of uniqueOutputAssetIDs) {
    const getAssetQuantity = assetQuantitySelector(assetId);
    const utxoTotal = getAssetQuantity(utxoWithTotals);
    const outputsTotal = getAssetQuantity(outputsWithTotals);
    if (outputsTotal > utxoTotal) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
  }
  const utxoCoinTotal = BigIntMath.sum(utxoWithTotals.map(({ totals: { coins } }) => coins));
  const outputsCoinTotal = BigIntMath.sum(outputsWithTotals.map(({ totals: { coins } }) => coins));
  if (outputsCoinTotal > utxoCoinTotal) {
    throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
  }
};
