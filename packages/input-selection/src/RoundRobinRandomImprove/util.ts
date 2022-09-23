/* eslint-disable func-style */
import { BigIntMath } from '@cardano-sdk/util';
import { Cardano } from '@cardano-sdk/core';
import { ImplicitValue } from '../types';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import uniq from 'lodash/uniq';

export interface ImplicitTokens {
  spend(assetId: Cardano.AssetId): bigint;
  input(assetId: Cardano.AssetId): bigint;
}

export interface RequiredImplicitValue {
  implicitCoin: Required<Cardano.util.ImplicitCoin>;
  implicitTokens: ImplicitTokens;
}

export interface RoundRobinRandomImproveArgs {
  utxo: Cardano.Utxo[];
  outputs: Cardano.TxOut[];
  uniqueTxAssetIDs: Cardano.AssetId[];
  implicitValue: RequiredImplicitValue;
  random: typeof Math.random;
}

export type PreProcessedArgs = Omit<RoundRobinRandomImproveArgs, 'random'>;

export interface UtxoSelection {
  utxoSelected: Cardano.Utxo[];
  utxoRemaining: Cardano.Utxo[];
}

export const mintToImplicitTokens = (mintMap: Cardano.TokenMap = new Map()) => {
  const mint = [...mintMap.entries()];
  const implicitTokensInput = new Map(mint.filter(([_, quantity]) => quantity > 0));
  const implicitTokensSpend = new Map(
    mint.filter(([_, quantity]) => quantity < 0).map(([assetId, quantity]) => [assetId, -quantity])
  );
  return { implicitTokensInput, implicitTokensSpend };
};

export const preProcessArgs = (
  availableUtxo: Set<Cardano.Utxo>,
  outputSet: Set<Cardano.TxOut>,
  partialImplicitValue?: ImplicitValue
): PreProcessedArgs => {
  const outputs = [...outputSet];
  const implicitCoin: Required<Cardano.util.ImplicitCoin> = {
    deposit: partialImplicitValue?.coin?.deposit || 0n,
    input: partialImplicitValue?.coin?.input || 0n
  };
  const mintMap: Cardano.TokenMap = partialImplicitValue?.mint || new Map();
  const { implicitTokensInput, implicitTokensSpend } = mintToImplicitTokens(mintMap);
  const implicitTokens: ImplicitTokens = {
    input: (assetId) => implicitTokensInput.get(assetId) || 0n,
    spend: (assetId) => implicitTokensSpend.get(assetId) || 0n
  };
  const uniqueOutputAssetIDs = uniq(outputs.flatMap(({ value: { assets } }) => [...(assets?.keys() || [])]));
  const uniqueTxAssetIDs = uniq([...uniqueOutputAssetIDs, ...mintMap.keys()]);
  return {
    implicitValue: { implicitCoin, implicitTokens },
    outputs,
    uniqueTxAssetIDs,
    utxo: [...availableUtxo]
  };
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
  implicitCoin: Required<Cardano.util.ImplicitCoin>
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
  uniqueTxAssetIDs: Cardano.AssetId[],
  utxo: Cardano.Utxo[],
  outputs: Cardano.TxOut[],
  { implicitCoin, implicitTokens }: RequiredImplicitValue
): void => {
  if (utxo.length === 0) {
    throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
  }
  const utxoValues = toValues(utxo);
  const outputsValues = toValues(outputs);
  for (const assetId of uniqueTxAssetIDs) {
    const getAssetQuantity = assetQuantitySelector(assetId);
    const utxoTotal = getAssetQuantity(utxoValues);
    const outputsTotal = getAssetQuantity(outputsValues);
    if (outputsTotal + implicitTokens.spend(assetId) > utxoTotal + implicitTokens.input(assetId)) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
  }
  assertIsCoinBalanceSufficient(utxoValues, outputsValues, implicitCoin);
};
