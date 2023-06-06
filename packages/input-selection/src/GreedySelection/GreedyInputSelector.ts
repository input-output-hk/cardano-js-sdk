/* eslint-disable max-params */
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionConstraints, SelectionResult } from '../types';
import {
  addTokenMaps,
  getCoinQuantity,
  hasNegativeAssetValue,
  sortByCoins,
  stubMaxSizeAddress,
  subtractTokenMaps,
  toValues
} from '../util';
import { splitChange } from './util';

/**
 * Greedy selection initialization properties.
 */
export interface GreedySelectorProps {
  /**
   * Callback that returns a map of addresses with their intended proportions expressed as weights.
   *
   * The weight is an integer, and relative to other weights in the map. For example, a map with two addresses and
   * respective weights of 1 and 2 means that we expect the selector to assign twice more change to the second address
   * than the first. This means that for every 3 Ada, 1 Ada should go to the first address, and 2 Ada should go to
   * the second.
   *
   * If the same distribution is needed for each address use the same weight (e.g. 1).
   *
   * This selector will create N change outputs at this change addresses with the given proportions.
   */
  getChangeAddresses: () => Promise<Map<Cardano.PaymentAddress, number>>;
}

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
const adjustOutputsForFee = async (
  changeLovelace: bigint,
  constraints: SelectionConstraints,
  inputs: Set<Cardano.Utxo>,
  outputs: Set<Cardano.TxOut>,
  changeOutputs: Array<Cardano.TxOut>,
  currentFee: bigint
): Promise<{ fee: bigint; change: Array<Cardano.TxOut> }> => {
  const totalOutputs = new Set([...outputs, ...changeOutputs]);
  const fee = await constraints.computeMinimumCost({
    change: [],
    fee: currentFee,
    inputs,
    outputs: totalOutputs
  });

  if (fee === changeLovelace) return { change: [], fee };

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

  if (!feeAccountedFor) {
    throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
  }

  return { change: [...updatedOutputs], fee };
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
const splitChangeAndComputeFee = async (
  inputs: Set<Cardano.Utxo>,
  outputs: Set<Cardano.TxOut>,
  changeLovelace: bigint,
  changeAssets: Cardano.TokenMap | undefined,
  constraints: SelectionConstraints,
  getChangeAddresses: () => Promise<Map<Cardano.PaymentAddress, number>>,
  fee: bigint
): Promise<{ fee: bigint; change: Array<Cardano.TxOut> }> => {
  const changeOutputs = await splitChange(
    getChangeAddresses,
    changeLovelace,
    changeAssets,
    constraints.computeMinimumCoinQuantity,
    constraints.tokenBundleSizeExceedsLimit,
    fee
  );

  const adjustedChangeOutputs = await adjustOutputsForFee(
    changeLovelace,
    constraints,
    inputs,
    outputs,
    changeOutputs,
    fee
  );

  // If the newly computed fee is higher than tha available balance for change,
  // but there are unallocated native assets, return the assets as change with 0n coins.
  if (adjustedChangeOutputs.fee >= changeLovelace) {
    return {
      change: [
        {
          address: stubMaxSizeAddress,
          value: {
            assets: changeAssets,
            coins: 0n
          }
        }
      ],
      fee: adjustedChangeOutputs.fee
    };
  }

  if (fee < adjustedChangeOutputs.fee) {
    return splitChangeAndComputeFee(
      inputs,
      outputs,
      changeLovelace,
      changeAssets,
      constraints,
      getChangeAddresses,
      adjustedChangeOutputs.fee
    );
  }

  return adjustedChangeOutputs;
};

/**
 * Selects all UTXOs to fulfill the amount required for the given outputs and return the remaining balance
 * as change.
 */
export class GreedyInputSelector implements InputSelector {
  #props: GreedySelectorProps;

  constructor(props: GreedySelectorProps) {
    this.#props = props;
  }

  async select(params: InputSelectionParameters): Promise<SelectionResult> {
    const { utxo: inputs, outputs, constraints, implicitValue } = params;
    const utxoValues = toValues([...inputs]);
    const outputsValues = toValues([...outputs]);
    const totalLovelaceInUtxoSet = getCoinQuantity(utxoValues);
    const totalLovelaceInOutputSet = getCoinQuantity(outputsValues);
    const totalAssetsInUtxoSet = coalesceValueQuantities(utxoValues).assets;
    const totalAssetsInOutputSet = coalesceValueQuantities(outputsValues).assets;
    const implicitCoinInput = implicitValue?.coin?.input || 0n;
    const implicitCoinOutput = implicitValue?.coin?.deposit || 0n;
    const implicitAssetInput = implicitValue?.mint || new Map<Cardano.AssetId, bigint>();
    const totalLovelaceInput = totalLovelaceInUtxoSet + implicitCoinInput;
    const totalLovelaceOutput = totalLovelaceInOutputSet + implicitCoinOutput;
    const totalAssetsInput = addTokenMaps(totalAssetsInUtxoSet, implicitAssetInput);

    const changeLovelace = totalLovelaceInput - totalLovelaceOutput;
    const changeAssets = subtractTokenMaps(totalAssetsInput, totalAssetsInOutputSet);

    if (inputs.size === 0 || totalLovelaceOutput > totalLovelaceInput || hasNegativeAssetValue(changeAssets))
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);

    const adjustedChangeOutputs = await splitChangeAndComputeFee(
      inputs,
      outputs,
      changeLovelace,
      changeAssets,
      constraints,
      this.#props.getChangeAddresses,
      0n
    );

    const change = adjustedChangeOutputs.change.filter(
      (out) => out.value.coins > 0n || (out.value.assets?.size || 0) > 0
    );

    if (changeLovelace - adjustedChangeOutputs.fee < 0n)
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);

    if (
      inputs.size >
      (await constraints.computeSelectionLimit({ change, fee: adjustedChangeOutputs.fee, inputs, outputs }))
    ) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    return {
      remainingUTxO: new Set<Cardano.Utxo>(), // This input selection always consumes all inputs.
      selection: {
        change,
        fee: adjustedChangeOutputs.fee,
        inputs,
        outputs
      }
    };
  }
}
