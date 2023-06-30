/* eslint-disable func-style, max-params */
import { BigNumber } from 'bignumber.js';
import { Cardano } from '@cardano-sdk/core';
import { ComputeMinimumCoinQuantity, TokenBundleSizeExceedsLimit } from '../types';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { addTokenMaps, isValidValue, sortByCoins, subtractTokenMaps } from '../util';

const PERCENTAGE_TOLERANCE = 0.05;

/**
 * Distribute the assets among the given outputs. The function will try to allocate all the assets in
 * the output with the biggest coin balance, if this fails, it will spill over the assets to the second output (and so on)
 * until it can distribute all assets among the outputs. If no such distribution can be found, the algorithm with fail.
 *
 * remark: At this point we are not ready to compute the fee, which would need to be subtracted from one of this change
 * outputs, so we are going to assume a high fee for the time being (2000000 lovelace). This will guarantee that the
 * outputs will remain valid even after the fee has been subtracted from the change output.
 *
 * @param outputs The outputs where to distribute the assets into.
 * @param computeMinimumCoinQuantity callback that computes the minimum coin quantity for the given UTXO.
 * @param tokenBundleSizeExceedsLimit callback that determines if a token bundle has exceeded its size limit.
 * @param fee The transaction fee to be discounted.
 * @returns a new change output array with the given assets allocated.
 */
const distributeAssets = (
  outputs: Array<Cardano.TxOut>,
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity,
  tokenBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit,
  fee: bigint
): Array<Cardano.TxOut> => {
  const adjustedOutputs = [...outputs];

  for (let i = 0; i < adjustedOutputs.length; ++i) {
    const output = adjustedOutputs[i];
    if (!isValidValue(output.value, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit, fee)) {
      if (i === adjustedOutputs.length - 1) {
        throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
      }

      if (!output.value.assets || output.value.assets.size === 0) {
        // If this output failed and doesn't contain any assets, it means there is not enough coins to cover
        // the min ADA coin per UTXO even after moving all the assets to the other outputs.
        throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
      }

      const splicedAsset = new Map([...output.value.assets!.entries()].splice(0, 1));
      const currentOutputNewAssets = subtractTokenMaps(output.value.assets, splicedAsset);
      const nextOutputNewAssets = addTokenMaps(adjustedOutputs[i + 1].value.assets, splicedAsset);

      output.value.assets = currentOutputNewAssets;
      adjustedOutputs[i + 1].value.assets = nextOutputNewAssets;

      return distributeAssets(adjustedOutputs, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit, fee);
    }
  }

  return adjustedOutputs;
};

/**
 * Splits the change proportionally between the given addresses. This algorithm makes
 * the best effort to be as accurate as possible in distributing the amounts, however, due to rounding
 * there may be a small error in the final distribution, I.E 8 lovelace divided in three equal parts will
 * yield 3, 3, 2 lovelace with an error of 33% in the last change output as lovelaces can't be further subdivided (The
 * error should be marginal for large amounts of lovelace).
 *
 * While lovelaces will be split according to the given distribution, native assets will use a different heuristic. We
 * will try to add all native assets to the UTXO with the most coins in the change outputs, if they don't 'fit', we will spill over to
 * the next change output and so on. We will assume a high fee (2 ADA) while doing this native asset allocation (this will guarantee that
 * when the actual fee is computed the largest change output can afford to discount it without becoming invalid). This is a rather
 * naive approach, but should work as long as the wallet is not at its maximum capacity for holding native assets due to minCoinAda
 * restrictions on the UTXOs.
 *
 * @param getChangeAddresses A callback that returns a list of addresses and their proportions.
 * @param totalChangeLovelace The total amount of lovelace in the change.
 * @param totalChangeAssets The total assets to be distributed as change.
 * @param computeMinimumCoinQuantity callback that computes the minimum coin quantity for the given UTXO.
 * @param tokenBundleSizeExceedsLimit callback that determines if a token bundle has exceeded its size limit.
 * @param fee The transaction fee to be discounted.
 */
export const splitChange = async (
  getChangeAddresses: () => Promise<Map<Cardano.PaymentAddress, number>>,
  totalChangeLovelace: bigint,
  totalChangeAssets: Cardano.TokenMap | undefined,
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity,
  tokenBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit,
  fee: bigint
): Promise<Array<Cardano.TxOut>> => {
  const changeAddresses = await getChangeAddresses();
  const totalWeight = [...changeAddresses.values()].reduce((sum, current) => sum + current, 0);
  const changeAsPercent = new Map([...changeAddresses.entries()].map((value) => [value[0], value[1] / totalWeight]));
  const totalPercentage = [...changeAsPercent.values()].reduce((sum, current) => sum + current, 0);

  // We are going to enforce that the given % 'mostly' add up to 100% (to account for division errors)
  if (Math.abs(1 - totalPercentage) > PERCENTAGE_TOLERANCE)
    throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient); // TODO: We need a new error for this types of failures

  const changeOutputs: Array<Cardano.TxOut> = [...changeAsPercent.entries()].map((val) => ({
    address: val[0],
    value: { coins: 0n }
  }));

  let runningTotal = 0n;
  const totalCoinAllocation = new BigNumber(totalChangeLovelace.toString());
  for (const txOut of changeOutputs) {
    const factor = new BigNumber(changeAsPercent.get(txOut.address)!);
    const coinAllocation = BigInt(totalCoinAllocation.multipliedBy(factor).toFixed(0, 0)); // Round up and no decimals

    runningTotal += coinAllocation;

    // If we over shoot the available coin change, subtract the extra from the last output.
    txOut.value.coins =
      runningTotal > totalChangeLovelace ? coinAllocation - (runningTotal - totalChangeLovelace) : coinAllocation;
  }

  if (runningTotal < totalChangeLovelace) {
    // This may be because the given proportions don't add up to 100% due to
    // rounding errors.
    const missingAllocation = totalChangeLovelace - runningTotal;
    changeOutputs[changeOutputs.length - 1].value.coins += missingAllocation;
  }

  const sortedOutputs = changeOutputs.sort(sortByCoins).filter((out) => out.value.coins > 0n);

  if (sortedOutputs && sortedOutputs.length > 0) sortedOutputs[0].value.assets = totalChangeAssets; // Add all assets to the 'biggest' output.

  if (!totalChangeAssets || totalChangeAssets.size === 0) return sortedOutputs;

  return distributeAssets(sortedOutputs, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit, fee);
};
