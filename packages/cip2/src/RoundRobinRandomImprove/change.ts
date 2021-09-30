import { CardanoSerializationLib, CSL, Ogmios } from '@cardano-sdk/core';
import { orderBy } from 'lodash-es';
import { ComputeMinimumCoinQuantity, TokenBundleSizeExceedsLimit } from '../types';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { TokenMap, OgmiosValue, ogmiosValueToCslValue } from '../util';
import {
  assetQuantitySelector,
  assetTotalsQuantitySelector,
  getCoinQuantity,
  getCoinTotalsQuantity,
  UtxoSelection,
  UtxoWithTotals
} from './util';

type EstimateTxFeeWithOriginalOutputs = (utxo: CSL.TransactionUnspentOutput[], change: CSL.Value[]) => Promise<bigint>;

interface ChangeComputationArgs {
  csl: CardanoSerializationLib;
  utxoSelection: UtxoSelection;
  outputValues: OgmiosValue[];
  uniqueOutputAssetIDs: string[];
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

const getLeftoverAssets = (utxoSelected: UtxoWithTotals[], uniqueOutputAssetIDs: string[]) => {
  const leftovers: Record<string, Array<bigint>> = {};
  for (const {
    totals: { assets }
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
  utxoSelected: UtxoWithTotals[],
  requestedAssetChangeBundles: OgmiosValue[],
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
      const smallestQuantity = quantities.pop();
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
  outputsWithTotals: OgmiosValue[],
  coinTotalRequested: bigint,
  coinChangeTotal: bigint,
  assetTotals: Record<string, { selected: bigint; requested: bigint }>
) => {
  let totalCoinBundled = 0n;
  const totalAssetsBundled: Record<string, bigint> = {};
  const bundles = outputsWithTotals.map((outputTotals) => {
    const coins = coinTotalRequested > 0n ? (coinChangeTotal * outputTotals.coins) / coinTotalRequested : 0n;
    totalCoinBundled += coins;
    if (!outputTotals.assets) {
      return { coins };
    }
    const assets: TokenMap = {};
    for (const assetId of Object.keys(outputTotals.assets)) {
      const outputAmount = outputTotals.assets[assetId];
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
  utxoSelected: UtxoWithTotals[],
  outputValues: OgmiosValue[],
  uniqueOutputAssetIDs: string[],
  fee: bigint
): OgmiosValue[] => {
  const assetTotals: Record<string, { selected: bigint; requested: bigint }> = {};
  for (const assetId of uniqueOutputAssetIDs) {
    assetTotals[assetId] = {
      selected: assetTotalsQuantitySelector(assetId)(utxoSelected),
      requested: assetQuantitySelector(assetId)(outputValues)
    };
  }
  const coinTotalSelected = getCoinTotalsQuantity(utxoSelected);
  const coinTotalRequested = getCoinQuantity(outputValues) + fee;
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
      const anyBundle = bundles.find(({ assets }) => typeof assets?.[assetId] === 'bigint');
      anyBundle.assets[assetId] = (anyBundle.assets[assetId] || 0n) + assetLost;
    }
  }

  return bundles;
};

/**
 * Picks one UTxO from remaining set and puts it to the selected set.
 * Precondition: utxoRemaining.length > 0
 */
const pickExtraRandomUtxo = ({ utxoRemaining, utxoSelected }: UtxoSelection): UtxoSelection => {
  const remainingUtxoOfOnlyCoin = utxoRemaining.filter(({ totals }) => !totals.assets);
  const pickFrom = remainingUtxoOfOnlyCoin.length > 0 ? remainingUtxoOfOnlyCoin : utxoRemaining;
  const pickIdx = Math.floor(Math.random() * pickFrom.length);
  const newUtxoSelected = [...utxoSelected, pickFrom[pickIdx]];
  const originalIdx = utxoRemaining.indexOf(pickFrom[pickIdx]);
  const newUtxoRemaining = [...utxoRemaining.slice(0, originalIdx), ...utxoRemaining.slice(originalIdx + 1)];
  return { utxoSelected: newUtxoSelected, utxoRemaining: newUtxoRemaining };
};

const coalesceChangeBundlesForMinCoinRequirement = (
  csl: CardanoSerializationLib,
  changeBundles: OgmiosValue[],
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity
): OgmiosValue[] | undefined => {
  if (changeBundles.length === 0) {
    return changeBundles;
  }

  let sortedBundles = orderBy(changeBundles, ({ coins }) => coins, 'desc');
  const satisfiesMinCoinRequirement = (valueQuantities: OgmiosValue) =>
    valueQuantities.coins >= computeMinimumCoinQuantity(ogmiosValueToCslValue(valueQuantities, csl).multiasset());

  while (sortedBundles.length > 1 && !satisfiesMinCoinRequirement(sortedBundles[sortedBundles.length - 1])) {
    const smallestBundle = sortedBundles.pop();
    sortedBundles[sortedBundles.length - 1] = Ogmios.util.coalesceValueQuantities(
      sortedBundles[sortedBundles.length - 1],
      smallestBundle
    );
    // Re-sort because last bundle is not necessarily the smallest one after merging it
    sortedBundles = orderBy(sortedBundles, ({ coins }) => coins, 'desc');
  }
  if (!satisfiesMinCoinRequirement(sortedBundles[0])) {
    // Coalesced all bundles to 1 and it's still less than min utxo value
    // eslint-disable-next-line consistent-return
    return undefined;
  }
  // Filter empty bundles
  // eslint-disable-next-line consistent-return
  return sortedBundles.filter((bundle) => bundle.coins > 0n || Object.keys(bundle.assets || {}).length > 0);
};

const computeChangeBundles = ({
  csl,
  utxoSelection,
  outputValues,
  uniqueOutputAssetIDs,
  computeMinimumCoinQuantity,
  fee = 0n
}: {
  csl: CardanoSerializationLib;
  utxoSelection: UtxoSelection;
  outputValues: OgmiosValue[];
  uniqueOutputAssetIDs: string[];
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity;
  fee?: bigint;
}): UtxoSelection & { changeBundles: OgmiosValue[] } => {
  const requestedAssetChangeBundles = computeRequestedAssetChangeBundles(
    utxoSelection.utxoSelected,
    outputValues,
    uniqueOutputAssetIDs,
    fee
  );
  const requestedAssetChangeBundlesWithLeftoverAssets = redistributeLeftoverAssets(
    utxoSelection.utxoSelected,
    requestedAssetChangeBundles,
    uniqueOutputAssetIDs
  );
  const changeBundles = coalesceChangeBundlesForMinCoinRequirement(
    csl,
    requestedAssetChangeBundlesWithLeftoverAssets,
    computeMinimumCoinQuantity
  );
  if (!changeBundles) {
    // Coalesced all bundles to 1 and it's still less than min utxo value
    if (utxoSelection.utxoRemaining.length > 0) {
      return computeChangeBundles({
        csl,
        utxoSelection: pickExtraRandomUtxo(utxoSelection),
        outputValues,
        uniqueOutputAssetIDs,
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
  csl: CardanoSerializationLib,
  changeBundles: OgmiosValue[],
  tokenBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit
) => {
  const values = changeBundles.map((bundle) => ogmiosValueToCslValue(bundle, csl));
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
  csl,
  computeMinimumCoinQuantity,
  tokenBundleSizeExceedsLimit,
  estimateTxFee,
  outputValues,
  uniqueOutputAssetIDs,
  utxoSelection
}: ChangeComputationArgs): Promise<ChangeComputationResult> => {
  const changeInclFee = computeChangeBundles({
    csl,
    utxoSelection,
    outputValues,
    uniqueOutputAssetIDs,
    computeMinimumCoinQuantity
  });

  // Calculate fee with change outputs that include fee.
  // It will cover the fee of final selection,
  // where fee is excluded from change bundles
  const fee = await estimateTxFee(
    changeInclFee.utxoSelected.map(({ utxo }) => utxo),
    changeBundlesToValues(csl, changeInclFee.changeBundles, tokenBundleSizeExceedsLimit)
  );

  // Ensure fee quantity is covered by current selection
  const outputValuesWithFee = [...outputValues, { coins: fee }];
  if (getCoinQuantity(outputValuesWithFee) > getCoinTotalsQuantity(changeInclFee.utxoSelected)) {
    if (changeInclFee.utxoRemaining.length === 0) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
    // Recompute change and fee with an extra selected UTxO
    return computeChangeAndAdjustForFee({
      csl,
      computeMinimumCoinQuantity,
      tokenBundleSizeExceedsLimit,
      outputValues,
      uniqueOutputAssetIDs,
      estimateTxFee,
      utxoSelection: pickExtraRandomUtxo(changeInclFee)
    });
  }

  const { changeBundles, utxoSelected, utxoRemaining } = computeChangeBundles({
    csl,
    utxoSelection: { utxoRemaining: changeInclFee.utxoRemaining, utxoSelected: changeInclFee.utxoSelected },
    outputValues,
    uniqueOutputAssetIDs,
    computeMinimumCoinQuantity,
    fee
  });

  return {
    remainingUTxO: utxoRemaining.map(({ utxo }) => utxo),
    inputs: utxoSelected.map(({ utxo }) => utxo),
    change: changeBundlesToValues(csl, changeBundles, tokenBundleSizeExceedsLimit),
    fee
  };
};
