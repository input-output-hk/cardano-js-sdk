import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';
import { ComputeMinimumCoinQuantity, TokenBundleSizeExceedsLimit, TxCosts } from '../types';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import {
  RequiredImplicitValue,
  UtxoSelection,
  assetQuantitySelector,
  getCoinQuantity,
  stubMaxSizeAddress,
  toValues
} from '../util';
import minBy from 'lodash/minBy.js';
import orderBy from 'lodash/orderBy.js';
import pick from 'lodash/pick.js';

type EstimateTxCostsWithOriginalOutputs = (utxo: Cardano.Utxo[], change: Cardano.Value[]) => Promise<TxCosts>;

interface ChangeComputationArgs {
  utxoSelection: UtxoSelection;
  outputValues: Cardano.Value[];
  uniqueTxAssetIDs: Cardano.AssetId[];
  implicitValue: RequiredImplicitValue;
  estimateTxCosts: EstimateTxCostsWithOriginalOutputs;
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity;
  tokenBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit;
  random: typeof Math.random;
}

interface ChangeComputationResult {
  remainingUTxO: Cardano.Utxo[];
  inputs: Cardano.Utxo[];
  change: Cardano.Value[];
  fee: Cardano.Lovelace;
  redeemers?: Array<Cardano.Redeemer>;
}

const getLeftoverAssets = (utxoSelected: Cardano.Utxo[], uniqueTxAssetIDs: Cardano.AssetId[]) => {
  const leftovers: Map<Cardano.AssetId, Array<bigint>> = new Map();
  for (const [
    _,
    {
      value: { assets }
    }
  ] of utxoSelected) {
    if (assets) {
      const leftoverAssetKeys = [...assets.keys()].filter((id) => !uniqueTxAssetIDs.includes(id));
      for (const assetKey of leftoverAssetKeys) {
        const quantity = assets.get(assetKey)!;
        if (quantity === 0n) continue;
        const assetLeftovers = leftovers.get(assetKey) || [];
        leftovers.set(assetKey, [...assetLeftovers, quantity]);
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
  utxoSelected: Cardano.Utxo[],
  requestedAssetChangeBundles: Cardano.Value[],
  uniqueTxAssetIDs: Cardano.AssetId[]
) => {
  const leftovers = getLeftoverAssets(utxoSelected, uniqueTxAssetIDs);
  // Distribute leftovers to result bundles
  const resultBundles = [...requestedAssetChangeBundles];
  for (const assetId of leftovers.keys()) {
    const quantities = orderBy(leftovers.get(assetId), (q) => q, 'desc');
    if (resultBundles.length === 0) {
      resultBundles.push({ coins: 0n });
    }
    while (quantities.length > resultBundles.length) {
      // Coalesce the smallest quantities together
      const smallestQuantity = quantities.pop()!;
      quantities[quantities.length - 1] += smallestQuantity;
    }
    for (const [idx, quantity] of quantities.entries()) {
      const originalBundle = resultBundles[idx];
      const originalBundleAssets = originalBundle.assets?.entries() || [];
      resultBundles.splice(idx, 1, {
        assets: new Map([...originalBundleAssets, [assetId, quantity]]),
        coins: originalBundle.coins
      });
    }
  }
  return resultBundles;
};

const createBundlePerOutput = (
  outputValues: Cardano.Value[],
  coinTotalRequested: bigint,
  coinChangeTotal: bigint,
  assetTotals: Map<Cardano.AssetId, { selected: bigint; requested: bigint }>
) => {
  let totalCoinBundled = 0n;
  const totalAssetsBundled: Cardano.TokenMap = new Map();
  const bundles = outputValues.map((value) => {
    const coins = coinTotalRequested > 0n ? (coinChangeTotal * value.coins) / coinTotalRequested : 0n;
    totalCoinBundled += coins;
    if (!value.assets) {
      return { coins };
    }
    const assets: Cardano.TokenMap = new Map();
    for (const [assetId, outputAmount] of value.assets.entries()) {
      const { selected, requested } = assetTotals.get(assetId)!;
      const assetChangeTotal = selected - requested;
      const assetChange = (assetChangeTotal * outputAmount) / selected;
      totalAssetsBundled.set(assetId, (totalAssetsBundled.get(assetId) || 0n) + assetChange);
      assets.set(assetId, assetChange);
    }
    return { assets, coins };
  });
  return { bundles, totalAssetsBundled, totalCoinBundled };
};

/**
 * Creates a new bundle if there are none (mutates 'bundles' object passed as arg).
 * Creates a new token map if there is none (mutates bundle.assets).
 *
 * @returns bundle with smallest token bundle.
 */
const smallestBundleTokenMap = (bundles: Cardano.Value[]) => {
  if (bundles.length === 0) {
    const bundle = { assets: new Map(), coins: 0n };
    bundles.push(bundle);
    return bundle.assets!;
  }
  const bundle = minBy(bundles, ({ assets }) => assets?.size || 0)!;
  if (!bundle.assets) bundle.assets = new Map();
  return bundle.assets!;
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
  utxoSelected: Cardano.Utxo[],
  outputValues: Cardano.Value[],
  uniqueTxAssetIDs: Cardano.AssetId[],
  { implicitCoin, implicitTokens }: RequiredImplicitValue,
  fee: Cardano.Lovelace
): Cardano.Value[] => {
  const assetTotals: Map<Cardano.AssetId, { selected: bigint; requested: bigint }> = new Map();
  const utxoSelectedValues = toValues(utxoSelected);
  for (const assetId of uniqueTxAssetIDs) {
    assetTotals.set(assetId, {
      requested: assetQuantitySelector(assetId)(outputValues) + implicitTokens.spend(assetId),
      selected: assetQuantitySelector(assetId)(utxoSelectedValues) + implicitTokens.input(assetId)
    });
  }
  const coinTotalSelected = getCoinQuantity(utxoSelectedValues) + implicitCoin.input;
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
  for (const assetId of uniqueTxAssetIDs) {
    const assetTotal = assetTotals.get(assetId)!;
    const bundled = totalAssetsBundled.get(assetId) || 0n;
    const assetLost = assetTotal.selected - assetTotal.requested - bundled;
    if (assetLost > 0n) {
      const anyChangeTokenBundle =
        bundles.find(({ assets }) => assets?.has(assetId))?.assets || smallestBundleTokenMap(bundles);
      const assetQuantityAlreadyInBundle = anyChangeTokenBundle.get(assetId) || 0n;
      anyChangeTokenBundle.set(assetId, assetQuantityAlreadyInBundle + assetLost);
    }
  }

  return bundles;
};

/** Picks one UTxO from remaining set and puts it to the selected set. Precondition: utxoRemaining.length > 0 */
const pickExtraRandomUtxo = (
  { utxoRemaining, utxoSelected }: UtxoSelection,
  random: typeof Math.random
): UtxoSelection => {
  const remainingUtxoOfOnlyCoin = utxoRemaining.filter(([_, { value }]) => !value.assets);
  const pickFrom = remainingUtxoOfOnlyCoin.length > 0 ? remainingUtxoOfOnlyCoin : utxoRemaining;
  const pickIdx = Math.floor(random() * pickFrom.length);
  const newUtxoSelected = [...utxoSelected, pickFrom[pickIdx]];
  const originalIdx = utxoRemaining.indexOf(pickFrom[pickIdx]);
  const newUtxoRemaining = [...utxoRemaining.slice(0, originalIdx), ...utxoRemaining.slice(originalIdx + 1)];
  return { utxoRemaining: newUtxoRemaining, utxoSelected: newUtxoSelected };
};

const mergeWithSmallestBundle = (values: Cardano.Value[], index: number): Cardano.Value[] => {
  let result = [...values];
  const toBeMerged = result.splice(index, 1)[0];

  if (result.length === 0) return [toBeMerged];

  const last = result.splice(-1, 1)[0];
  const merged = coalesceValueQuantities([toBeMerged, last]);

  result = [...result, merged];
  result = orderBy(result, ({ coins }) => coins, 'desc');

  return result;
};

export const coalesceChangeBundlesForMinCoinRequirement = (
  changeBundles: Cardano.Value[],
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity
): Cardano.Value[] | undefined => {
  if (changeBundles.length === 0) {
    return changeBundles;
  }

  const noZeroQuantityAssetChangeBundles = changeBundles.map(
    ({ coins, assets }): Cardano.Value => ({
      assets: assets ? new Map([...assets.entries()].filter(([_, quantity]) => quantity > 0n)) : undefined,
      coins
    })
  );
  let sortedBundles = orderBy(noZeroQuantityAssetChangeBundles, ({ coins }) => coins, 'desc');

  // Assuming change will be sent to a grouped address.
  // We will use a stub address here, the actual address is not important, we're only concerned with size of the output.
  const satisfiesMinCoinRequirement = (value: Cardano.Value) => {
    const stubTxOut: Cardano.TxOut = { address: stubMaxSizeAddress, value };
    return value.coins >= computeMinimumCoinQuantity(stubTxOut);
  };

  let allBundlesSatisfyMinCoin = false;

  while (sortedBundles.length > 1 && !allBundlesSatisfyMinCoin) {
    allBundlesSatisfyMinCoin = true;
    for (let i = sortedBundles.length - 1; i >= 0; --i) {
      const satisfies = satisfiesMinCoinRequirement(sortedBundles[i]);

      allBundlesSatisfyMinCoin = allBundlesSatisfyMinCoin && satisfies;

      if (!satisfies) {
        sortedBundles = mergeWithSmallestBundle(sortedBundles, i);
        break;
      }
    }
  }

  if (!satisfiesMinCoinRequirement(sortedBundles[0])) {
    // Coalesced all bundles to 1 and it's still less than min utxo value
    return undefined;
  }
  // Filter empty bundles
  return sortedBundles.filter((bundle) => bundle.coins > 0n || (bundle.assets?.size || 0) > 0);
};

const computeChangeBundles = ({
  utxoSelection,
  outputValues,
  uniqueTxAssetIDs,
  implicitValue,
  computeMinimumCoinQuantity,
  fee = 0n
}: {
  utxoSelection: UtxoSelection;
  outputValues: Cardano.Value[];
  uniqueTxAssetIDs: Cardano.AssetId[];
  implicitValue: RequiredImplicitValue;
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity;
  fee?: bigint;
}): (UtxoSelection & { changeBundles: Cardano.Value[] }) | false => {
  const requestedAssetChangeBundles = computeRequestedAssetChangeBundles(
    utxoSelection.utxoSelected,
    outputValues,
    uniqueTxAssetIDs,
    implicitValue,
    fee
  );
  const requestedAssetChangeBundlesWithLeftoverAssets = redistributeLeftoverAssets(
    utxoSelection.utxoSelected,
    requestedAssetChangeBundles,
    uniqueTxAssetIDs
  );
  const changeBundles = coalesceChangeBundlesForMinCoinRequirement(
    requestedAssetChangeBundlesWithLeftoverAssets,
    computeMinimumCoinQuantity
  );
  if (!changeBundles) {
    return false;
  }
  return { changeBundles, ...utxoSelection };
};

const validateChangeBundles = (
  changeBundles: Cardano.Value[],
  tokenBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit
) => {
  for (const { assets } of changeBundles) {
    if (!assets) continue;
    if (tokenBundleSizeExceedsLimit(assets)) {
      // Algorithm could be improved to attempt to rebalance the bundles
      throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
    }
  }
  return changeBundles;
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
  estimateTxCosts,
  outputValues,
  uniqueTxAssetIDs,
  implicitValue,
  random,
  utxoSelection
}: ChangeComputationArgs): Promise<ChangeComputationResult> => {
  const recomputeChangeAndAdjustForFeeWithExtraUtxo = (currentUtxoSelection: UtxoSelection) => {
    if (currentUtxoSelection.utxoRemaining.length > 0) {
      return computeChangeAndAdjustForFee({
        computeMinimumCoinQuantity,
        estimateTxCosts,
        implicitValue,
        outputValues,
        random,
        tokenBundleSizeExceedsLimit,
        uniqueTxAssetIDs,
        utxoSelection: pickExtraRandomUtxo(currentUtxoSelection, random)
      });
    }
    // This is not a great error type for this, because the spec says
    // "due to various restrictions that coin selection algorithms impose on themselves when selecting UTxO entries."
    // Sometimes this happens due to blockchain restriction on minimum utxo coin quantity,
    // not due to the algorithm restriction.
    throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
  };

  const selectionWithChangeAndFee = computeChangeBundles({
    computeMinimumCoinQuantity,
    implicitValue,
    outputValues,
    uniqueTxAssetIDs,
    utxoSelection
  });
  if (!selectionWithChangeAndFee) return recomputeChangeAndAdjustForFeeWithExtraUtxo(utxoSelection);

  // Calculate fee with change outputs that include fee.
  // It will cover the fee of final selection,
  // where fee is excluded from change bundles
  const estimatedCosts = await estimateTxCosts(
    selectionWithChangeAndFee.utxoSelected,
    validateChangeBundles(selectionWithChangeAndFee.changeBundles, tokenBundleSizeExceedsLimit)
  );

  // Ensure fee quantity is covered by current selection
  const totalOutputCoin = getCoinQuantity(outputValues) + estimatedCosts.fee + implicitValue.implicitCoin.deposit;
  const totalInputCoin =
    getCoinQuantity(toValues(selectionWithChangeAndFee.utxoSelected)) + implicitValue.implicitCoin.input;
  if (totalOutputCoin > totalInputCoin) {
    if (selectionWithChangeAndFee.utxoRemaining.length === 0) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
    // Recompute change and fee with an extra selected UTxO
    return recomputeChangeAndAdjustForFeeWithExtraUtxo(selectionWithChangeAndFee);
  }

  const finalSelection = computeChangeBundles({
    computeMinimumCoinQuantity,
    fee: estimatedCosts.fee,
    implicitValue,
    outputValues,
    uniqueTxAssetIDs,
    utxoSelection: pick(selectionWithChangeAndFee, ['utxoRemaining', 'utxoSelected'])
  });

  if (!finalSelection) {
    return recomputeChangeAndAdjustForFeeWithExtraUtxo(selectionWithChangeAndFee);
  }

  const { changeBundles, utxoSelected, utxoRemaining } = finalSelection;

  return {
    change: validateChangeBundles(changeBundles, tokenBundleSizeExceedsLimit),
    fee: estimatedCosts.fee,
    inputs: utxoSelected,
    redeemers: estimatedCosts.redeemers,
    remainingUTxO: utxoRemaining
  };
};
