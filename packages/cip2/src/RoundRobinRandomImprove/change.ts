import { CardanoSerializationLib, CSL } from '@cardano-sdk/cardano-serialization-lib';
import { Ogmios } from '@cardano-sdk/core';
import { orderBy } from 'lodash-es';
import { ComputeMinimumCoinQuantity, TokenBundleSizeExceedsLimit } from '../types';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { AssetQuantities, ValueQuantities, valueQuantitiesToValue } from '../util';
import { assetQuantitySelector, getCoinQuantity, OutputWithTotals, UtxoSelection, UtxoWithTotals } from './util';

type EstimateTxFeeWithOriginalOutputs = (utxo: CSL.TransactionUnspentOutput[], change: CSL.Value[]) => Promise<bigint>;

interface ChangeComputationArgs {
  csl: CardanoSerializationLib;
  utxoSelection: UtxoSelection;
  outputsWithTotals: OutputWithTotals[];
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
  requestedAssetChangeBundles: ValueQuantities[],
  uniqueOutputAssetIDs: string[]
) => {
  const leftovers = getLeftoverAssets(utxoSelected, uniqueOutputAssetIDs);
  // Distribute leftovers to result bundles
  const resultBundles = [...requestedAssetChangeBundles];
  for (const assetId in leftovers) {
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
  outputsWithTotals: OutputWithTotals[],
  coinTotalRequested: bigint,
  coinChangeTotal: bigint,
  assetTotals: Record<string, { selected: bigint; requested: bigint }>
) => {
  let totalCoinBundled = 0n;
  const totalAssetsBundled: Record<string, bigint> = {};
  const bundles = outputsWithTotals.map(({ totals: outputTotals }) => {
    const coins = coinTotalRequested > 0n ? (coinChangeTotal * outputTotals.coins) / coinTotalRequested : 0n;
    totalCoinBundled += coins;
    if (!outputTotals.assets) {
      return { coins };
    }
    const assets: AssetQuantities = {};
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
  outputsWithTotals: OutputWithTotals[],
  uniqueOutputAssetIDs: string[]
): ValueQuantities[] => {
  const assetTotals: Record<string, { selected: bigint; requested: bigint }> = {};
  for (const assetId of uniqueOutputAssetIDs) {
    const getQuantity = assetQuantitySelector(assetId);
    assetTotals[assetId] = {
      selected: getQuantity(utxoSelected),
      requested: getQuantity(outputsWithTotals)
    };
  }
  const coinTotalSelected = getCoinQuantity(utxoSelected);
  const coinTotalRequested = getCoinQuantity(outputsWithTotals);
  const coinChangeTotal = coinTotalSelected - coinTotalRequested;

  const { totalCoinBundled, bundles, totalAssetsBundled } = createBundlePerOutput(
    outputsWithTotals,
    coinTotalRequested,
    coinChangeTotal,
    assetTotals
  );

  // Add quantities lost by integer division to any bundle
  const coinLost = coinChangeTotal - totalCoinBundled;
  if (coinLost > 0) {
    bundles[0].coins += coinLost;
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
  changeBundles: ValueQuantities[],
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity
): ValueQuantities[] | undefined => {
  let sortedBundles = orderBy(changeBundles, ({ coins }) => coins, 'desc');
  const satisfiesMinCoinRequirement = (valueQuantities: ValueQuantities) =>
    valueQuantities.coins >= computeMinimumCoinQuantity(valueQuantitiesToValue(valueQuantities, csl).multiasset());

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
  // TODO: remove empty bundles
  // eslint-disable-next-line consistent-return
  return sortedBundles;
};

const computeChangeBundles = (
  csl: CardanoSerializationLib,
  utxoSelection: UtxoSelection,
  outputsWithTotals: OutputWithTotals[],
  uniqueOutputAssetIDs: string[],
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity
): UtxoSelection & { changeBundles: ValueQuantities[] } => {
  const requestedAssetChangeBundles = computeRequestedAssetChangeBundles(
    utxoSelection.utxoSelected,
    outputsWithTotals,
    uniqueOutputAssetIDs
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
      return computeChangeBundles(
        csl,
        pickExtraRandomUtxo(utxoSelection),
        outputsWithTotals,
        uniqueOutputAssetIDs,
        computeMinimumCoinQuantity
      );
    }
    // This is not a great error type for this, because the spec says
    // "due to various restrictions that coin selection algorithms impose on themselves when selecting UTxO entries."
    // This happens due to blockchain restriction on minimum utxo coin quantity, not due to the algorithm restriction.
    throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
  }
  return { changeBundles, ...utxoSelection };
};
/**
 * 1. Compute change bundles and coalesce them to cover min ADA requirement. Select additional UTxO if needed.
 * 2. Compute fee and verify that change coin covers it. If not, select an additional UTxO and retry.
 *
 * @throws InputSelectionError { UtxoFullyDepleted, UtxoBalanceInsufficient }
 */
export const computeChangeAndAdjustForFee = async ({
  csl,
  computeMinimumCoinQuantity,
  tokenBundleSizeExceedsLimit,
  estimateTxFee,
  outputsWithTotals,
  uniqueOutputAssetIDs,
  utxoSelection
}: ChangeComputationArgs): Promise<ChangeComputationResult> => {
  const { changeBundles, utxoSelected, utxoRemaining } = computeChangeBundles(
    csl,
    utxoSelection,
    outputsWithTotals,
    uniqueOutputAssetIDs,
    computeMinimumCoinQuantity
  );

  const change = changeBundles.map((bundle) => valueQuantitiesToValue(bundle, csl));
  for (const value of change) {
    const multiasset = value.multiasset();
    if (!multiasset) continue;
    if (tokenBundleSizeExceedsLimit(multiasset)) {
      // Algorithm could be improved to attempt to rebalance the bundles
      throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
    }
  }

  const fee = await estimateTxFee(
    utxoSelected.map(({ utxo }) => utxo),
    change
  );

  if (getCoinQuantity(changeBundles.map((totals) => ({ totals }))) < fee) {
    if (utxoRemaining.length === 0) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
    // Recompute change and fee with an extra selected UTxO
    return computeChangeAndAdjustForFee({
      csl,
      computeMinimumCoinQuantity,
      tokenBundleSizeExceedsLimit,
      outputsWithTotals,
      uniqueOutputAssetIDs,
      estimateTxFee,
      utxoSelection: pickExtraRandomUtxo({ utxoSelected, utxoRemaining })
    });
  }

  return {
    remainingUTxO: utxoRemaining.map(({ utxo }) => utxo),
    inputs: utxoSelected.map(({ utxo }) => utxo),
    change,
    fee
  };
};
