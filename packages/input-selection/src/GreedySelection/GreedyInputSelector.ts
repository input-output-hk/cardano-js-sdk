/* eslint-disable max-params */
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import {
  addTokenMaps,
  getCoinQuantity,
  hasNegativeAssetValue,
  sortUtxoByTxIn,
  subtractTokenMaps,
  toValues
} from '../util';
import { splitChangeAndComputeFee } from './util';

/** Greedy selection initialization properties. */
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

/** Selects all UTXOs to fulfill the amount required for the given outputs and return the remaining balance as change. */
export class GreedyInputSelector implements InputSelector {
  #props: GreedySelectorProps;

  constructor(props: GreedySelectorProps) {
    this.#props = props;
  }

  async select(params: InputSelectionParameters): Promise<SelectionResult> {
    const { preSelectedUtxo, utxo: inputs, outputs, constraints, implicitValue } = params;
    const allInputs = new Set([...inputs, ...preSelectedUtxo]);
    const utxoValues = toValues([...allInputs]);
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

    if (allInputs.size === 0 || totalLovelaceOutput > totalLovelaceInput || hasNegativeAssetValue(changeAssets))
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);

    const adjustedChangeOutputs = await splitChangeAndComputeFee(
      allInputs,
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
      allInputs.size >
      (await constraints.computeSelectionLimit({ change, fee: adjustedChangeOutputs.fee, inputs: allInputs, outputs }))
    ) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    return {
      remainingUTxO: new Set<Cardano.Utxo>(), // This input selection always consumes all inputs.
      selection: {
        change,
        fee: adjustedChangeOutputs.fee,
        inputs: new Set([...allInputs].sort(sortUtxoByTxIn)),
        outputs
      }
    };
  }
}
