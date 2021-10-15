import { Ogmios, CSL } from '@cardano-sdk/core';
import { orderBy } from 'lodash-es';
import { ComputeMinimumCoinQuantity, TokenBundleSizeExceedsLimit } from '../types';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import {
  assetQuantitySelector,
  assetWithValueQuantitySelector,
  getCoinQuantity,
  getWithValuesCoinQuantity,
  ImplicitCoinBigint,
  UtxoSelection,
  UtxoWithValue
} from './util';

type EstimateTxFeeWithOriginalOutputs = (utxo: CSL.TransactionUnspentOutput[], change: CSL.Value[]) => Promise<bigint>;

interface ChangeComputationArgs {
  utxoSelection: UtxoSelection;
  outputValues: Ogmios.Value[];
  uniqueOutputAssetIDs: string[];
  implicitCoin: ImplicitCoinBigint;
  estimateTxFee: EstimateTxFeeWithOriginalOutputs;
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity;
  tokenBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit;
}

interface ChangeComputationResult {
  remainingUTxO: CSL.TransactionUnspentOutput[];
  inputs: CSL.TransactionUnspentOutput[];
  change: CSL.Value[];
  fee: bigint;
}

const getLeftoverAssets = (utxoSelected: UtxoWithValue[], uniqueOutputAssetIDs: string[]) => {
  const leftovers: Record<string, Array<bigint>> = {};
  for (const {
    value: { assets }
  } of utxoSelected) {
    if (assets) {
      const leftoverAssetKeys = Object.keys(assets).filter((id) => !uniqueOutputAssetIDs.includes(id));
      for (const assetKey of leftoverAssetKeys) {
        (leftovers[assetKey] ||= []).push(assets[assetKey]);
      }
    }
  }
  return leftovers;
};

/**
 * Redistribute additionally-selected tokens not present in the original outputs to the change bundles, where:
 * - if there are fewer quantities for a given token than the number of change bundles,
 *   include these quantities without changing them.
 * - if there are more quantities for a given token than the number of change bundles,
 *   coalesce the smallest quantities together.
 */
const redistributeLeftoverAssets = (
  utxoSelected: UtxoWithValue[],
  requestedAssetChangeBundles: Ogmios.Value[],
  uniqueOutputAssetIDs: string[]
) => {
  const leftovers = getLeftoverAssets(utxoSelected, uniqueOutputAssetIDs);
  // Distribute leftovers to result bundles
  const resultBundles = [...requestedAssetChangeBundles];
  for (const assetId in leftovers) {
    if (resultBundles.length === 0) {
      resultBundles.push({ coins: 0n });
    }
    const quantities = orderBy(leftovers[assetId], (q) => q, 'desc');
    while (quantities.length > resultBundles.length) {
      // Coalesce the smallest quantities together
      const smallestQuantity = quantities.pop()!;
      quantities[quantities.length - 1] += smallestQuantity;
    }
    for (const [idx, quantity] of quantities.entries()) {
      const originalBundle = resultBundles[idx];
      resultBundles.splice(idx, 1, {
        coins: originalBundle.coins,
        assets: {
          ...originalBundle.assets,
          [assetId]: quantity
        }
      });
    }
  }
  return resultBundles;
};

const createBundlePerOutput = (
  outputValues: Ogmios.Value[],
  coinTotalRequested: bigint,
  coinChangeTotal: bigint,
  assetTotals: Record<string, { selected: bigint; requested: bigint }>
) => {
  let totalCoinBundled = 0n;
  const totalAssetsBundled: Record<string, bigint> = {};
  const bundles = outputValues.map((value) => {
    const coins = coinTotalRequested > 0n ? (coinChangeTotal * value.coins) / coinTotalRequested : 0n;
    totalCoinBundled += coins;
    if (!value.assets) {
      return { coins };
    }
    const assets: Ogmios.TokenMap = {};
    for (const assetId of Object.keys(value.assets)) {
      const outputAmount = value.assets[assetId];
      const { selected, requested } = assetTotals[assetId];
      const assetChangeTotal = selected - requested;
      const assetChange = (assetChangeTotal * outputAmount) / selected;
      totalAssetsBundled[assetId] = (totalAssetsBundled[assetId] || 0n) + assetChange;
      assets[assetId] = assetChange;
    }
    return { coins, assets };
  });
  return { totalCoinBundled, bundles, totalAssetsBundled };
};

/**
 * Divide any excess token quantities (inputs − outputs) into change bundles, where:
 * - there is exactly one change bundle for each output.
 * - the quantity of a given token in a change bundle
 *   is proportional to the quantity of that token in the corresponding output.
 * - the total quantity of a given token across all change bundles
 *   is equal to the total excess quantity of that token.
 */
const computeRequestedAssetChangeBundles = (
  utxoSelected: UtxoWithValue[],
  outputValues: Ogmios.Value[],
  uniqueOutputAssetIDs: string[],
  implicitCoin: ImplicitCoinBigint,
  fee: bigint
): Ogmios.Value[] => {
  const assetTotals: Record<string, { selected: bigint; requested: bigint }> = {};
  for (const assetId of uniqueOutputAssetIDs) {
    assetTotals[assetId] = {
      selected: assetWithValueQuantitySelector(assetId)(utxoSelected),
      requested: assetQuantitySelector(assetId)(outputValues)
    };
  }
  const coinTotalSelected = getWithValuesCoinQuantity(utxoSelected) + implicitCoin.input;
  const coinTotalRequested = getCoinQuantity(outputValues) + fee + implicitCoin.deposit;
  const coinChangeTotal = coinTotalSelected - coinTotalRequested;

  const { totalCoinBundled, bundles, totalAssetsBundled } = createBundlePerOutput(
    outputValues,
    coinTotalRequested,
    coinChangeTotal,
    assetTotals
  );

  // Add quantities lost by integer division to any bundle
  const coinLost = coinChangeTotal - totalCoinBundled;
  if (coinLost > 0) {
    if (bundles.length === 0) {
      bundles.push({ coins: coinLost });
    } else {
      bundles[0].coins += coinLost;
    }
  }
  for (const assetId of uniqueOutputAssetIDs) {
    const assetTotal = assetTotals[assetId];
    const assetLost = assetTotal.selected - assetTotal.requested - totalAssetsBundled[assetId];
    if (assetLost > 0n) {
      const anyBundle = bundles.find(({ assets }) => typeof assets?.[assetId] === 'bigint')!;
      anyBundle.assets![assetId] = (anyBundle.assets![assetId] || 0n) + assetLost;
    }
  }

  return bundles;
};

/**
 * Picks one UTxO from remaining set and puts it to the selected set.
 * Precondition: utxoRemaining.length > 0
 */
const pickExtraRandomUtxo = ({ utxoRemaining, utxoSelected }: UtxoSelection): UtxoSelection => {
  const remainingUtxoOfOnlyCoin = utxoRemaining.filter(({ value }) => !value.assets);
  const pickFrom = remainingUtxoOfOnlyCoin.length > 0 ? remainingUtxoOfOnlyCoin : utxoRemaining;
  const pickIdx = Math.floor(Math.random() * pickFrom.length);
  const newUtxoSelected = [...utxoSelected, pickFrom[pickIdx]];
  const originalIdx = utxoRemaining.indexOf(pickFrom[pickIdx]);
  const newUtxoRemaining = [...utxoRemaining.slice(0, originalIdx), ...utxoRemaining.slice(originalIdx + 1)];
  return { utxoSelected: newUtxoSelected, utxoRemaining: newUtxoRemaining };
};

const coalesceChangeBundlesForMinCoinRequirement = (
  changeBundles: Ogmios.Value[],
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity
): Ogmios.Value[] | undefined => {
  if (changeBundles.length === 0) {
    return changeBundles;
  }

  let sortedBundles = orderBy(changeBundles, ({ coins }) => coins, 'desc');
  const satisfiesMinCoinRequirement = (valueQuantities: Ogmios.Value) =>
    valueQuantities.coins >= computeMinimumCoinQuantity(Ogmios.ogmiosToCsl.value(valueQuantities).multiasset());

  while (sortedBundles.length > 1 && !satisfiesMinCoinRequirement(sortedBundles[sortedBundles.length - 1])) {
    const smallestBundle = sortedBundles.pop()!;
    sortedBundles[sortedBundles.length - 1] = Ogmios.util.coalesceValueQuantities([
      sortedBundles[sortedBundles.length - 1],
      smallestBundle
    ]);
    // Re-sort because last bundle is not necessarily the smallest one after merging it
    sortedBundles = orderBy(sortedBundles, ({ coins }) => coins, 'desc');
  }
  if (!satisfiesMinCoinRequirement(sortedBundles[0])) {
    // Coalesced all bundles to 1 and it's still less than min utxo value
    return undefined;
  }
  // Filter empty bundles
  return sortedBundles.filter((bundle) => bundle.coins > 0n || Object.keys(bundle.assets || {}).length > 0);
};

const computeChangeBundles = ({
  utxoSelection,
  outputValues,
  uniqueOutputAssetIDs,
  implicitCoin,
  computeMinimumCoinQuantity,
  fee = 0n
}: {
  utxoSelection: UtxoSelection;
  outputValues: Ogmios.Value[];
  uniqueOutputAssetIDs: string[];
  implicitCoin: ImplicitCoinBigint;
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity;
  fee?: bigint;
}): UtxoSelection & { changeBundles: Ogmios.Value[] } => {
  const requestedAssetChangeBundles = computeRequestedAssetChangeBundles(
    utxoSelection.utxoSelected,
    outputValues,
    uniqueOutputAssetIDs,
    implicitCoin,
    fee
  );
  const requestedAssetChangeBundlesWithLeftoverAssets = redistributeLeftoverAssets(
    utxoSelection.utxoSelected,
    requestedAssetChangeBundles,
    uniqueOutputAssetIDs
  );
  const changeBundles = coalesceChangeBundlesForMinCoinRequirement(
    requestedAssetChangeBundlesWithLeftoverAssets,
    computeMinimumCoinQuantity
  );
  if (!changeBundles) {
    // Coalesced all bundles to 1 and it's still less than min utxo value
    if (utxoSelection.utxoRemaining.length > 0) {
      return computeChangeBundles({
        utxoSelection: pickExtraRandomUtxo(utxoSelection),
        outputValues,
        uniqueOutputAssetIDs,
        implicitCoin,
        computeMinimumCoinQuantity,
        fee
      });
    }
    // This is not a great error type for this, because the spec says
    // "due to various restrictions that coin selection algorithms impose on themselves when selecting UTxO entries."
    // This happens due to blockchain restriction on minimum utxo coin quantity, not due to the algorithm restriction.
    throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
  }
  return { changeBundles, ...utxoSelection };
};

const changeBundlesToValues = (
  changeBundles: Ogmios.Value[],
  tokenBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit
) => {
  const values = changeBundles.map((bundle) => Ogmios.ogmiosToCsl.value(bundle));
  for (const value of values) {
    const multiasset = value.multiasset();
    if (!multiasset) continue;
    if (tokenBundleSizeExceedsLimit(multiasset)) {
      // Algorithm could be improved to attempt to rebalance the bundles
      throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
    }
  }
  return values;
};

/**
 * 1. Compute change bundles with fee included and coalesce them to cover min ADA requirement.
 * 2. Compute min fee for selection that includes fee in it's change bundles.
 * 3. Re-compute change bundles without fee included.
 * 4. Select additional UTxO if
 *  - Total change quantity doesn't cover min UTxO valueu
 *  - Selected UTxO doesn't cover outputs+fee
 *
 * @throws InputSelectionError { UtxoFullyDepleted, UtxoBalanceInsufficient }
 */
export const computeChangeAndAdjustForFee = async ({
  computeMinimumCoinQuantity,
  tokenBundleSizeExceedsLimit,
  estimateTxFee,
  outputValues,
  uniqueOutputAssetIDs,
  implicitCoin,
  utxoSelection
}: ChangeComputationArgs): Promise<ChangeComputationResult> => {
  const changeInclFee = computeChangeBundles({
    utxoSelection,
    outputValues,
    uniqueOutputAssetIDs,
    implicitCoin,
    computeMinimumCoinQuantity
  });

  // Calculate fee with change outputs that include fee.
  // It will cover the fee of final selection,
  // where fee is excluded from change bundles
  const fee = await estimateTxFee(
    changeInclFee.utxoSelected.map(({ utxo }) => utxo),
    changeBundlesToValues(changeInclFee.changeBundles, tokenBundleSizeExceedsLimit)
  );

  // Ensure fee quantity is covered by current selection
  const totalOutputCoin = getCoinQuantity(outputValues) + fee + implicitCoin.deposit;
  const totalInputCoin = getWithValuesCoinQuantity(changeInclFee.utxoSelected) + implicitCoin.input;
  if (totalOutputCoin > totalInputCoin) {
    if (changeInclFee.utxoRemaining.length === 0) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
    // Recompute change and fee with an extra selected UTxO
    return computeChangeAndAdjustForFee({
      computeMinimumCoinQuantity,
      tokenBundleSizeExceedsLimit,
      outputValues,
      uniqueOutputAssetIDs,
      estimateTxFee,
      implicitCoin,
      utxoSelection: pickExtraRandomUtxo(changeInclFee)
    });
  }

  const { changeBundles, utxoSelected, utxoRemaining } = computeChangeBundles({
    utxoSelection: { utxoRemaining: changeInclFee.utxoRemaining, utxoSelected: changeInclFee.utxoSelected },
    outputValues,
    uniqueOutputAssetIDs,
    implicitCoin,
    computeMinimumCoinQuantity,
    fee
  });

  return {
    remainingUTxO: utxoRemaining.map(({ utxo }) => utxo),
    inputs: utxoSelected.map(({ utxo }) => utxo),
    change: changeBundlesToValues(changeBundles, tokenBundleSizeExceedsLimit),
    fee
  };
};
