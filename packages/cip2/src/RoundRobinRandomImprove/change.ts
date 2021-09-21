import { TransactionUnspentOutput, Value } from '@emurgo/cardano-serialization-lib-nodejs';
import { orderBy } from 'lodash-es';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { AssetQuantities, coalesceValueQuantities, CslUtils, ValueQuantities } from '../util';
import { assetQuantitySelector, getCoinQuantity, OutputWithTotals, UtxoSelection, UtxoWithTotals } from './util';

type EstimateTxFeeWithOriginalOutputs = (utxo: TransactionUnspentOutput[], change: Value[]) => Promise<bigint>;

interface ChangeComputationArgs {
  cslUtils: CslUtils;
  minUtxoCoinValue: bigint;
  utxoSelection: UtxoSelection;
  outputsWithTotals: OutputWithTotals[];
  uniqueOutputAssetIDs: string[];
  estimateTxFee: EstimateTxFeeWithOriginalOutputs;
}

interface ChangeComputationResult {
  remainingUTxO: TransactionUnspentOutput[];
  inputs: TransactionUnspentOutput[];
  change: Value[];
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
  for (const id in leftovers) {
    const quantities = orderBy(leftovers[id], (q) => q, 'desc');
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
          [id]: quantity
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
  const bundles = outputsWithTotals
    .map(({ totals: outputTotals }) => {
      const coins = coinTotalRequested > 0n ? (coinChangeTotal * outputTotals.coins) / coinTotalRequested : 0n;
      totalCoinBundled += coins;
      if (!outputTotals.assets) {
        return { coins };
      }
      const assets: AssetQuantities = {};
      for (const id of Object.keys(outputTotals.assets)) {
        const outputAmount = outputTotals.assets[id] || 0n;
        const { selected, requested } = assetTotals[id];
        const assetChangeTotal = selected - requested;
        const assetChange = (assetChangeTotal * outputAmount) / selected;
        totalAssetsBundled[id] = (totalAssetsBundled[id] || 0n) + assetChange;
        assets[id] = assetChange;
      }
      return { coins, assets };
    })
    .filter(({ coins, assets }) => coins > 0n || (assets && Object.keys(assets).length > 0));
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
  for (const id of uniqueOutputAssetIDs) {
    const getQuantity = assetQuantitySelector(id);
    assetTotals[id] = {
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
  for (const id of uniqueOutputAssetIDs) {
    const assetTotal = assetTotals[id];
    const assetLost = assetTotal.selected - assetTotal.requested - totalAssetsBundled[id];
    if (assetLost > 0n) {
      const anyBundle = bundles.find(({ assets }) => assets?.[id]) || bundles[0];
      anyBundle.assets ||= {};
      anyBundle.assets[id] = (anyBundle.assets[id] || 0n) + assetLost;
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

const coalesceChangeBundlesForMinAdaRequirement = (
  changeBundles: ValueQuantities[],
  minUtxoCoinValue: bigint
): ValueQuantities[] | undefined => {
  if (changeBundles.length === 0) {
    return changeBundles;
  }
  let sortedBundles = orderBy(changeBundles, ({ coins }) => coins, 'desc');
  while (sortedBundles.length > 1 && sortedBundles[sortedBundles.length - 1].coins < minUtxoCoinValue) {
    const smallestBundle = sortedBundles.pop();
    sortedBundles[sortedBundles.length - 1] = coalesceValueQuantities(
      sortedBundles[sortedBundles.length - 1],
      smallestBundle
    );
    // Re-sort because last bundle is not necessarily the smallest one after merging it
    sortedBundles = orderBy(sortedBundles, ({ coins }) => coins, 'desc');
  }
  if (sortedBundles[0].coins < minUtxoCoinValue) {
    // Coalesced all bundles to 1 and it's still less than min utxo value
    // eslint-disable-next-line consistent-return
    return undefined;
  }
  return sortedBundles;
};

const computeChangeBundles = (
  utxoSelection: UtxoSelection,
  outputsWithTotals: OutputWithTotals[],
  uniqueOutputAssetIDs: string[],
  minUtxoValue: bigint
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
  const changeBundles = coalesceChangeBundlesForMinAdaRequirement(
    requestedAssetChangeBundlesWithLeftoverAssets,
    minUtxoValue
  );
  if (!changeBundles) {
    // Coalesced all bundles to 1 and it's still less than min utxo value
    if (utxoSelection.utxoRemaining.length > 0) {
      return computeChangeBundles(
        pickExtraRandomUtxo(utxoSelection),
        outputsWithTotals,
        uniqueOutputAssetIDs,
        minUtxoValue
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
  cslUtils,
  estimateTxFee,
  minUtxoCoinValue,
  outputsWithTotals,
  uniqueOutputAssetIDs,
  utxoSelection
}: ChangeComputationArgs): Promise<ChangeComputationResult> => {
  const { changeBundles, utxoSelected, utxoRemaining } = computeChangeBundles(
    utxoSelection,
    outputsWithTotals,
    uniqueOutputAssetIDs,
    minUtxoCoinValue
  );

  const change = changeBundles.map((bundle) => cslUtils.valueQuantitiesToValue(bundle));
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
      cslUtils,
      outputsWithTotals,
      uniqueOutputAssetIDs,
      estimateTxFee,
      minUtxoCoinValue,
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
