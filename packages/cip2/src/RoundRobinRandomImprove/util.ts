/* eslint-disable func-style */
import { BigIntMath, Cardano } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { uniq } from 'lodash-es';

export interface RoundRobinRandomImproveArgs {
  utxo: Cardano.Utxo[];
  outputs: Cardano.TxOut[];
  uniqueOutputAssetIDs: Cardano.AssetId[];
  implicitCoin: Required<Cardano.ImplicitCoin>;
  random: typeof Math.random;
}

export interface UtxoSelection {
  utxoSelected: Cardano.Utxo[];
  utxoRemaining: Cardano.Utxo[];
}

const noImplicitCoin = {
  deposit: 0n,
  input: 0n
};

export const preprocessArgs = (
  availableUtxo: Set<Cardano.Utxo>,
  outputSet: Set<Cardano.TxOut>,
  partialImplicitCoin: Cardano.ImplicitCoin = noImplicitCoin
): Omit<RoundRobinRandomImproveArgs, 'random'> => {
  const outputs = [...outputSet];
  const uniqueOutputAssetIDs = uniq(outputs.flatMap(({ value: { assets } }) => [...(assets?.keys() || [])]));
  const implicitCoin: Required<Cardano.ImplicitCoin> = {
    deposit: partialImplicitCoin.deposit || 0n,
    input: partialImplicitCoin.input || 0n
  };
  return { implicitCoin, outputs, uniqueOutputAssetIDs, utxo: [...availableUtxo] };
};

const isUtxoArray = (outputsOrUtxo: Cardano.TxOut[] | Cardano.Utxo[]): outputsOrUtxo is Cardano.Utxo[] =>
  outputsOrUtxo.length > 0 && Array.isArray(outputsOrUtxo[0]);

export function toValues(outputs: Cardano.TxOut[]): Cardano.Value[];
export function toValues(utxo: Cardano.Utxo[]): Cardano.Value[];
/**
 * Map either TxOut[] or Utxo[] to Value[]
 */
export function toValues(outputsOrUtxo: Cardano.TxOut[] | Cardano.Utxo[]): Cardano.Value[] {
  if (isUtxoArray(outputsOrUtxo)) {
    return outputsOrUtxo.map(([_, { value }]) => value);
  }
  return outputsOrUtxo.map(({ value }) => value);
}

export const assetQuantitySelector =
  (id: Cardano.AssetId) =>
  (quantities: Cardano.Value[]): bigint =>
    BigIntMath.sum(quantities.map(({ assets }) => assets?.get(id) || 0n));

export const getCoinQuantity = (quantities: Cardano.Value[]): bigint =>
  BigIntMath.sum(quantities.map(({ coins }) => coins));

export const assertIsCoinBalanceSufficient = (
  utxoValues: Cardano.Value[],
  outputValues: Cardano.Value[],
  implicitCoin: Required<Cardano.ImplicitCoin>
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
  utxo: Cardano.Utxo[],
  outputs: Cardano.TxOut[],
  implicitCoin: Required<Cardano.ImplicitCoin>
): void => {
  if (utxo.length === 0) {
    throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
  }
  const utxoValues = toValues(utxo);
  const outputsValues = toValues(outputs);
  for (const assetId of uniqueOutputAssetIDs) {
    const getAssetQuantity = assetQuantitySelector(assetId);
    const utxoTotal = getAssetQuantity(utxoValues);
    const outputsTotal = getAssetQuantity(outputsValues);
    if (outputsTotal > utxoTotal) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
  }
  assertIsCoinBalanceSufficient(utxoValues, outputsValues, implicitCoin);
};
