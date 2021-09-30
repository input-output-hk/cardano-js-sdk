import { BigIntMath, CSL } from '@cardano-sdk/core';
import { uniq } from 'lodash-es';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { OgmiosValue, valueToValueQuantities } from '../util';

export interface Totals {
  totals: OgmiosValue;
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

export const totalsToValueQuantities = (totals: Totals[]) => totals.map((t) => t.totals);
export const assetQuantitySelector =
  (id: string) =>
  (quantities: OgmiosValue[]): bigint =>
    BigIntMath.sum(quantities.map(({ assets }) => assets?.[id] || 0n));
export const assetTotalsQuantitySelector =
  (id: string) =>
  (totals: Totals[]): bigint =>
    assetQuantitySelector(id)(totalsToValueQuantities(totals));
export const getCoinQuantity = (quantities: OgmiosValue[]): bigint =>
  BigIntMath.sum(quantities.map(({ coins }) => coins));
export const getCoinTotalsQuantity = (totals: Totals[]): bigint => getCoinQuantity(totalsToValueQuantities(totals));

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
