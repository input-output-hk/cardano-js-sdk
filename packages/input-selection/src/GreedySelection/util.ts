/* eslint-disable func-style, max-params */
import { BigNumber } from 'bignumber.js';
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';
import { ComputeMinimumCoinQuantity, SelectionConstraints, TokenBundleSizeExceedsLimit } from '../types';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { addTokenMaps, isValidValue, sortByCoins, stubMaxSizeAddress } from '../util';

const PERCENTAGE_TOLERANCE = 0.05;

/**
 * Distribute the assets evenly among the UTXOs. This algorithm place one native asset at each UTXO, once
 * the UTXO list is exhausted, it starts over from the first UTXO. If at some point one of the UTXOs in the list
 * goes over the TokenBundleSizeExceedsLimit or computeMinimumCoinQuantity, it's removed from the list of eligible
 * UTXOs to receive native assets.
 *
 * The algorithm ends when there are no more native assets to distribute, or there are no remaining UTXOs that are
 * eligible (in which case it will throw UtxoFullyDepleted).
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

  if (adjustedOutputs.length === 0) return adjustedOutputs;

  const totalAssets = coalesceValueQuantities(adjustedOutputs.map((out) => out.value)).assets;

  if (!totalAssets || totalAssets.size === 0) return adjustedOutputs;

  for (const utxo of adjustedOutputs) utxo.value.assets = undefined;

  let i = 0;
  const availableOutputs = adjustedOutputs;
  const alreadyFullOutputs = [];

  while (totalAssets.size > 0) {
    const splicedAsset = new Map([...totalAssets.entries()].splice(0, 1));
    const currentUtxoIndex = i % availableOutputs.length;
    const currentValue = { ...availableOutputs[currentUtxoIndex].value };

    currentValue.assets = addTokenMaps(currentValue.assets, splicedAsset);

    if (!isValidValue(currentValue, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit, fee)) {
      alreadyFullOutputs.push(...availableOutputs.splice(currentUtxoIndex, 1));
    } else {
      availableOutputs[currentUtxoIndex].value = currentValue;
      totalAssets.delete([...splicedAsset.keys()][0]);
    }

    if (availableOutputs.length === 0) throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
    ++i;
  }

  return [...adjustedOutputs, ...alreadyFullOutputs];
};

/**
 * Computes the lowest amount a change output is allowed to have during change
 * distribution within the same stake address.
 *
 * @param amount The total available lovelace amount.
 */
const getMinUtxoAmount = (amount: bigint): bigint => {
  // The smaller the value, the bigger the amount of UTXOs that will be present in the stake address.
  const granularityFactor = new BigNumber(0.03);

  // Computes the smallest number with the same number of tens, for example: 3_725_000, will yield 1_000_000.
  let tens = amount.toString().length - 1;
  let minLovelaceStr = '1';

  while (tens > 0) {
    minLovelaceStr += '0';
    --tens;
  }

  return BigInt(new BigNumber(minLovelaceStr).multipliedBy(granularityFactor).toFixed(0, 0));
};

/**
 * Given a change output, split it following an exponential distribution. For example
 * 100000 will yield:
 *
 * [ 50000n, 25000n, 12500n, 6250n, 3125n, 3125n ]
 *
 * We chose an exponential distribution (n**2), because it gives the best compromise in granularity
 * and amount of UTXOs generated. We don't want too many UTXOs as this could make the transaction exceed the max allow
 * TX size, but at the same time we want a diverse and big enough amount of UTXOs to reasonably build any TX with a fairly
 * small amount of inputs.
 *
 * Using an exponential distribution will also guarantee that the number of UTXOs generated will be more or less the same
 * regardless of the amount of total available lovelace, for example:
 *
 * 10      => [ 5n,      2n,      1n,      1n,     1n             ]
 * 100     => [ 50n,     25n,     12n,     6n,     3n,     4n     ]
 * 1000    => [ 500n,    250n,    125n,    62n,    31n,    32n    ]
 * 10000   => [ 5000n,   2500n,   1250n,   625n,   312n,   313n   ]
 * 100000  => [ 50000n,  25000n,  12500n,  6250n,  3125n,  3125n  ]
 * 1000000 => [ 500000n, 250000n, 125000n, 62500n, 31250n, 31250n ]
 *
 * @param output The output to be split.
 * @param computeMinimumCoinQuantity ComputeMinimumCoinQuantity.
 * @param fee current expected fee.
 */
const splitChangeOutput = (
  output: Cardano.TxOut,
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity,
  fee: bigint
): Array<Cardano.TxOut> => {
  const amount = output.value.coins;
  const minUtxoAdaAmount = getMinUtxoAmount(amount);

  let remaining = amount;
  let runningAmount = 0n;
  const amounts = new Array<bigint>();
  const divisor = new BigNumber(2);

  while (remaining >= minUtxoAdaAmount) {
    const val = BigInt(new BigNumber(remaining.toString()).dividedBy(divisor).toFixed(0, 0));

    const updatedRemaining = remaining - val;
    if (
      updatedRemaining <= minUtxoAdaAmount ||
      updatedRemaining <=
        computeMinimumCoinQuantity({
          address: output.address,
          value: { assets: output.value.assets, coins: amount - runningAmount }
        }) +
          fee
    ) {
      amounts.push(amount - runningAmount); // Add all that remains to account for rounding errors
      break;
    }

    runningAmount += val;

    amounts.push(val);

    remaining -= val;
  }

  return amounts.map((coins) => ({
    address: output.address,
    value: { assets: output.value.assets, coins }
  }));
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

  const splitOutputs = changeOutputs.flatMap((output) => splitChangeOutput(output, computeMinimumCoinQuantity, fee));
  const sortedOutputs = splitOutputs.sort(sortByCoins).filter((out) => out.value.coins > 0n);

  if (sortedOutputs && sortedOutputs.length > 0) sortedOutputs[0].value.assets = totalChangeAssets; // Add all assets to the 'biggest' output.

  if (!totalChangeAssets || totalChangeAssets.size === 0) return sortedOutputs;

  return distributeAssets(sortedOutputs, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit, fee);
};

/**
 * Given a set of input and outputs, compute the fee. Then extract the fee from the change output
 * with the highest value.
 *
 * @param changeLovelace The available amount of lovelace to be used as change.
 * @param constraints The selection constraints.
 * @param inputs The inputs of the transaction.
 * @param outputs The outputs of the transaction.
 * @param changeOutputs The list of change outputs.
 * @param currentFee The current computed fee for this selection.
 */
export const adjustOutputsForFee = async (
  changeLovelace: bigint,
  constraints: SelectionConstraints,
  inputs: Set<Cardano.Utxo>,
  outputs: Set<Cardano.TxOut>,
  changeOutputs: Array<Cardano.TxOut>,
  currentFee: bigint
): Promise<{
  fee: bigint;
  change: Array<Cardano.TxOut>;
  feeAccountedFor: boolean;
  redeemers?: Array<Cardano.Redeemer>;
}> => {
  const totalOutputs = new Set([...outputs, ...changeOutputs]);
  const { fee, redeemers } = await constraints.computeMinimumCost({
    change: [],
    fee: currentFee,
    inputs,
    outputs: totalOutputs
  });

  if (fee === changeLovelace) return { change: [], fee, feeAccountedFor: true, redeemers };

  if (changeLovelace < fee) throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);

  const updatedOutputs = [...changeOutputs];

  updatedOutputs.sort(sortByCoins);

  let feeAccountedFor = false;
  for (const output of updatedOutputs) {
    const adjustedCoins = output.value.coins - fee;

    if (adjustedCoins >= constraints.computeMinimumCoinQuantity(output)) {
      output.value.coins = adjustedCoins;
      feeAccountedFor = true;
      break;
    }
  }

  return { change: [...updatedOutputs], fee, feeAccountedFor, redeemers };
};

/**
 * Recursively compute the fee and compute change outputs until it finds a set of change outputs that satisfies the fee.
 *
 * @param inputs The inputs of the transaction.
 * @param outputs The outputs of the transaction.
 * @param changeLovelace The total amount of lovelace in the change.
 * @param changeAssets The total assets to be distributed as change.
 * @param constraints The selection constraints.
 * @param getChangeAddresses A callback that returns a list of addresses and their proportions.
 * @param fee The current computed fee for this selection.
 */
export const splitChangeAndComputeFee = async (
  inputs: Set<Cardano.Utxo>,
  outputs: Set<Cardano.TxOut>,
  changeLovelace: bigint,
  changeAssets: Cardano.TokenMap | undefined,
  constraints: SelectionConstraints,
  getChangeAddresses: () => Promise<Map<Cardano.PaymentAddress, number>>,
  fee: bigint
): Promise<{ fee: bigint; change: Array<Cardano.TxOut>; feeAccountedFor: boolean }> => {
  const changeOutputs = await splitChange(
    getChangeAddresses,
    changeLovelace,
    changeAssets,
    constraints.computeMinimumCoinQuantity,
    constraints.tokenBundleSizeExceedsLimit,
    fee
  );

  let adjustedChangeOutputs = await adjustOutputsForFee(
    changeLovelace,
    constraints,
    inputs,
    outputs,
    changeOutputs,
    fee
  );

  // If the newly computed fee is higher than the available balance for change,
  // but there are unallocated native assets, return the assets as change with 0n coins.
  if (adjustedChangeOutputs.fee >= changeLovelace) {
    const result = {
      change: [
        {
          address: stubMaxSizeAddress,
          value: {
            assets: changeAssets,
            coins: 0n
          }
        }
      ],
      fee: adjustedChangeOutputs.fee,
      feeAccountedFor: true
    };

    if (result.change[0].value.coins < constraints.computeMinimumCoinQuantity(result.change[0]))
      throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);

    return result;
  }

  if (fee < adjustedChangeOutputs.fee) {
    adjustedChangeOutputs = await splitChangeAndComputeFee(
      inputs,
      outputs,
      changeLovelace,
      changeAssets,
      constraints,
      getChangeAddresses,
      adjustedChangeOutputs.fee
    );

    if (adjustedChangeOutputs.change.length === 0)
      throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
  }

  for (const out of adjustedChangeOutputs.change) {
    if (out.value.coins < constraints.computeMinimumCoinQuantity(out))
      throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
  }

  if (!adjustedChangeOutputs.feeAccountedFor) throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);

  return adjustedChangeOutputs;
};
