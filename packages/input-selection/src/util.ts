/* eslint-disable func-style, complexity, sonarjs/cognitive-complexity */

import { BigIntMath } from '@cardano-sdk/util';
import { Cardano } from '@cardano-sdk/core';
import { ComputeMinimumCoinQuantity, ImplicitValue, TokenBundleSizeExceedsLimit } from './types';
import { InputSelectionError, InputSelectionFailure } from './InputSelectionError';
import uniq from 'lodash/uniq';

export const stubMaxSizeAddress = Cardano.PaymentAddress(
  'addr_test1qqydn46r6mhge0kfpqmt36m6q43knzsd9ga32n96m89px3nuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475qypp3m9'
);

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
  changeAddress: Cardano.PaymentAddress;
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
  changeAddress: Cardano.PaymentAddress,
  partialImplicitValue?: ImplicitValue
): PreProcessedArgs => {
  const outputs = [...outputSet];
  const implicitCoin: Required<Cardano.util.ImplicitCoin> = {
    deposit: partialImplicitValue?.coin?.deposit || 0n,
    input: partialImplicitValue?.coin?.input || 0n,
    reclaimDeposit: partialImplicitValue?.coin?.reclaimDeposit || 0n,
    withdrawals: partialImplicitValue?.coin?.withdrawals || 0n
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
    changeAddress,
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
/** Map either TxOut[] or Utxo[] to Value[] */
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

/**
 * Sorts the given TxOuts by coin size in descending order.
 *
 * @param lhs The left-hand side of the comparison operation.
 * @param rhs The left-hand side of the comparison operation.
 */
export const sortByCoins = (lhs: Cardano.TxOut, rhs: Cardano.TxOut) => {
  if (lhs.value.coins > rhs.value.coins) {
    return -1;
  } else if (lhs.value.coins < rhs.value.coins) {
    return 1;
  }
  return 0;
};

/**
 * Given two TokenMaps, compute a TokenMap with the difference between the left-hand side and the right-hand side.
 *
 * @param lhs the left-hand side of the subtraction operation.
 * @param rhs the right-hand side of the subtraction operation.
 * @returns The difference between both TokenMaps.
 */
export const subtractTokenMaps = (
  lhs: Cardano.TokenMap | undefined,
  rhs: Cardano.TokenMap | undefined
): Cardano.TokenMap | undefined => {
  if (!rhs) {
    if (!lhs) return undefined;

    const nonEmptyValues = new Map<Cardano.AssetId, bigint>();

    for (const [key, value] of lhs.entries()) {
      if (value !== 0n) nonEmptyValues.set(key, value);
    }

    return nonEmptyValues;
  }

  if (!lhs) {
    const negativeValues = new Map<Cardano.AssetId, bigint>();

    for (const [key, value] of rhs.entries()) {
      if (value !== 0n) negativeValues.set(key, -value);
    }

    return negativeValues;
  }

  const result = new Map<Cardano.AssetId, bigint>();
  const intersection = new Array<Cardano.AssetId>();

  // any element that is present in the lhs and not in the rhs will be added as a positive value
  for (const [key, value] of lhs.entries()) {
    if (rhs.has(key)) {
      intersection.push(key);
      continue;
    }

    if (value !== 0n) result.set(key, value);
  }

  // any element that is present in the rhs and not in the lhs will be added as a negative value
  for (const [key, value] of rhs.entries()) {
    if (lhs.has(key)) {
      intersection.push(key);
      continue;
    }

    if (value !== 0n) result.set(key, -value);
  }

  // Elements present in both maps will be subtracted (lhs - rhs)
  const uniqIntersection = uniq(intersection);

  for (const id of uniqIntersection) {
    const lshVal = lhs.get(id);
    const rshVal = rhs.get(id);
    const remainingCoins = lshVal! - rshVal!;

    if (remainingCoins !== 0n) result.set(id, remainingCoins);
  }

  return result;
};

/**
 * Given two TokenMaps, compute a TokenMap with the addition between the left-hand side and the right-hand side.
 *
 * @param lhs the left-hand side of the addition operation.
 * @param rhs the right-hand side of the addition operation.
 * @returns The addition between both TokenMaps.
 */
export const addTokenMaps = (
  lhs: Cardano.TokenMap | undefined,
  rhs: Cardano.TokenMap | undefined
): Cardano.TokenMap | undefined => {
  if (!lhs) return rhs;
  if (!rhs) return lhs;

  const result = new Map<Cardano.AssetId, bigint>();
  const intersection = new Array<Cardano.AssetId>();

  for (const [key, value] of lhs.entries()) {
    if (rhs.has(key)) {
      intersection.push(key);
      continue;
    }

    if (value !== 0n) result.set(key, value);
  }

  for (const [key, value] of rhs.entries()) {
    if (lhs.has(key)) {
      intersection.push(key);
      continue;
    }

    if (value !== 0n) result.set(key, value);
  }

  // Elements present in both maps will be added together (lhs + rhs)
  const uniqIntersection = uniq(intersection);

  for (const id of uniqIntersection) {
    const lshVal = lhs.get(id);
    const rshVal = rhs.get(id);

    if (lshVal! + rshVal! !== 0n) result.set(id, lshVal! + rshVal!);
  }

  return result;
};

/**
 * Gets whether the given token map contains any assets which quantity is less than 0.
 *
 * @param assets The assets to be checked for negative values.
 * @returns true if any of the assets has a negative value; otherwise, false.
 */
export const hasNegativeAssetValue = (assets: Cardano.TokenMap | undefined): boolean => {
  if (!assets) return false;

  const values = [...assets.values()];
  return values.some((quantity) => quantity < 0n);
};

/**
 * Gets whether the given value will produce a valid UTXO.
 *
 * @param value The value to be tested.
 * @param computeMinimumCoinQuantity callback that computes the minimum coin quantity for the given UTXO.
 * @param tokenBundleSizeExceedsLimit callback that determines if a token bundle has exceeded its size limit.
 * @param feeToDiscount The fee that could be discounted later on from this output (defaults to 0).
 * @returns true if the value is valid; otherwise, false.
 */
export const isValidValue = (
  value: Cardano.Value,
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity,
  tokenBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit,
  feeToDiscount: bigint
): boolean => {
  let isValid = value.coins - feeToDiscount >= computeMinimumCoinQuantity({ address: stubMaxSizeAddress, value });

  if (value.assets) isValid = isValid && !tokenBundleSizeExceedsLimit(value.assets);

  return isValid;
};
