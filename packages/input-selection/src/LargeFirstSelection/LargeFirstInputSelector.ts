/* eslint-disable max-params */
import { Cardano, coalesceValueQuantities } from '@cardano-sdk/core';
import { ChangeAddressResolver } from '../ChangeAddress';
import {
  ImplicitTokens,
  MAX_U64,
  UtxoSelection,
  addTokenMaps,
  getCoinQuantity,
  hasNegativeAssetValue,
  mintToImplicitTokens,
  sortByAssetQuantity,
  sortByCoins,
  sortUtxoByTxIn,
  stubMaxSizeAddress,
  subtractTokenMaps,
  toValues
} from '../util';
import {
  ImplicitValue,
  InputSelectionParameters,
  InputSelector,
  SelectionConstraints,
  SelectionResult
} from '../types';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';

import { computeChangeAndAdjustForFee } from '../change';

import uniq from 'lodash/uniq.js';

/**
 * A `PickAdditionalUtxo` callback for the large-first strategy.
 *
 * The callback simply:
 * 1. Sorts the remaining UTxOs by coin quantity (largest first).
 * 2. Picks the first UTxO from the sorted list.
 * 3. Returns the updated `UtxoSelection`.
 */
const pickAdditionalLargestUtxo = ({ utxoRemaining, utxoSelected }: UtxoSelection): UtxoSelection => {
  if (utxoRemaining.length === 0) {
    return { utxoRemaining, utxoSelected };
  }

  const sorted = utxoRemaining.sort(([, a], [, b]) => sortByCoins(a, b));
  const [picked, ...newRemaining] = sorted;

  return {
    utxoRemaining: newRemaining,
    utxoSelected: [...utxoSelected, picked]
  };
};

/** LargeFirst selection initialization properties. */
export interface LargeFirstSelectorProps {
  changeAddressResolver: ChangeAddressResolver;
}

/**
 * Input selector that implements a "large-first" strategy.
 *
 * This strategy selects the largest UTxOs per asset, one asset at a time, until the requirements
 * of all assets in the outputs + fees and implicit values are satisfied.
 */
export class LargeFirstSelector implements InputSelector {
  #props: LargeFirstSelectorProps;

  /** Creates a new instance of the LargeFirstSelector. */
  constructor(props: LargeFirstSelectorProps) {
    this.#props = props;
  }

  /**
   * Selects inputs using a large-first strategy:
   * Selects largest UTxOs per asset until target is met
   * Then selects largest UTxOs by Ada
   * Then iteratively adds more UTxOs if needed to cover fees
   *
   * @param params Input selection parameters (available UTxOs, outputs, constraints, etc.)
   * @returns A complete selection including inputs, outputs, change, and fee.
   * @throws {InputSelectionError} If the selection cannot satisfy the outputs and fees.
   */
  async select(params: InputSelectionParameters): Promise<SelectionResult> {
    const { utxo, preSelectedUtxo, outputs, constraints, implicitValue } = params;

    const preSelected = [...preSelectedUtxo];
    const available = [...utxo].filter(
      ([txIn]) => !preSelected.some(([preTxIn]) => preTxIn.txId === txIn.txId && preTxIn.index === txIn.index)
    );
    const allAvailable = [...preSelected, ...available];

    const { totalLovelaceOutput, outputAssets } = this.#computeNetImplicitSelectionValues(
      new Set<Cardano.Utxo>(allAvailable),
      outputs,
      implicitValue
    );

    let workingUtxo = new Set<Cardano.Utxo>(preSelected);
    workingUtxo = this.#selectAssets(outputAssets, allAvailable, [...workingUtxo]);
    workingUtxo = this.#selectLovelace(
      totalLovelaceOutput,
      allAvailable,
      workingUtxo,
      implicitValue?.coin?.input ?? 0n
    );

    const { finalSelection, fee, change } = await this.#expandUtxosUntilFeeCovered(
      workingUtxo,
      outputs,
      allAvailable,
      outputAssets,
      constraints,
      this.#props.changeAddressResolver,
      implicitValue
    );

    const limit = await constraints.computeSelectionLimit({ change, fee, inputs: finalSelection, outputs });
    if (finalSelection.size > limit) throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);

    return {
      remainingUTxO: this.#computeRemainingUtxo([...utxo], finalSelection),
      selection: {
        change,
        fee,
        inputs: new Set([...finalSelection].sort(sortUtxoByTxIn)),
        outputs
      }
    };
  }

  /**
   * Aggregate Lovelace that enters and leaves the transaction,
   * taking implicit withdrawals / deposits into account.
   *
   * @param inputs   Array of `Value`s held by the selected UTxOs.
   * @param outputs  Array of explicit transaction outputs.
   * @param implicit Optional implicit values.
   * @returns An object with
   * `totalIn`  — Lovelace provided by UTxOs + withdrawals
   * `totalOut` — Lovelace required for explicit outputs + deposits
   */
  #aggregateLovelace(
    inputs: Cardano.Value[],
    outputs: Cardano.Value[],
    implicit?: ImplicitValue
  ): { totalIn: bigint; totalOut: bigint } {
    const utxoAda = getCoinQuantity(inputs);
    const outputAda = getCoinQuantity(outputs);
    const withdrawAda = implicit?.coin?.input ?? 0n;
    const depositAda = implicit?.coin?.deposit ?? 0n;

    return {
      totalIn: utxoAda + withdrawAda,
      totalOut: outputAda + depositAda
    };
  }

  /**
   * Compute two token maps:
   * - required: the exact quantity of every asset that must be provided by inputs in order to satisfy explicit outputs plus any burns.
   * - available: the quantity of every asset that is actually provided by inputs + positive mint.
   *
   * @param inputs   Values contained in the UTxOs selected so far.
   * @param outputs  Values required by the user’s explicit transaction outputs.
   * @param implicit Optional `mint` map (positive = forge, negative = burn).
   * @returns `{ required, available }`
   */
  #aggregateAssets(
    inputs: Cardano.Value[],
    outputs: Cardano.Value[],
    implicit?: ImplicitValue
  ): {
    required: Cardano.TokenMap;
    available: Cardano.TokenMap;
  } {
    const outputsMap = coalesceValueQuantities(outputs).assets ?? new Map<Cardano.AssetId, bigint>();
    const utxoMap = coalesceValueQuantities(inputs).assets;
    const mint = implicit?.mint ?? new Map<Cardano.AssetId, bigint>();

    const posMint = new Map<Cardano.AssetId, bigint>();
    const negMint = new Map<Cardano.AssetId, bigint>();

    for (const [id, q] of mint) (q > 0n ? posMint : negMint).set(id, q > 0n ? q : -q);

    let required = addTokenMaps(outputsMap, negMint);
    required = subtractTokenMaps(required, posMint) ?? new Map<Cardano.AssetId, bigint>();

    const available = addTokenMaps(utxoMap, posMint) ?? new Map<Cardano.AssetId, bigint>();

    return { available, required };
  }

  /**
   * Computes the total Lovelace and asset output requirements, including the effects
   * of implicit values such as key deposits, withdrawals, and minting/burning.
   *
   * Minting and burning are treated as negative or positive contributions to input balance,
   * and are subtracted from the output requirements.
   *
   * @param inputs The full set of selected UTxOs (including pre-selected).
   * @param outputs The transaction outputs.
   * @param implicitValue Optional implicit values including deposits, withdrawals, and minting.
   * @returns An object with:
   * `totalLovelaceInput`: Sum of all input Lovelace, including withdrawals.
   * `totalLovelaceOutput`: Sum of all output Lovelace, including deposits.
   * `outputAssets`: Asset requirements after accounting for minting/burning.
   * @throws {InputSelectionError} If balance is insufficient to satisfy the target.
   */
  #computeNetImplicitSelectionValues(
    inputs: Set<Cardano.Utxo>,
    outputs: Set<Cardano.TxOut>,
    implicitValue?: ImplicitValue
  ): {
    totalLovelaceInput: bigint;
    totalLovelaceOutput: bigint;
    outputAssets: Cardano.TokenMap;
  } {
    const inputVals = toValues([...inputs]);
    const outputVals = toValues([...outputs]);

    const { totalIn, totalOut } = this.#aggregateLovelace(inputVals, outputVals, implicitValue);
    const { required, available } = this.#aggregateAssets(inputVals, outputVals, implicitValue);

    const changeAda = totalIn - totalOut;
    const changeAssets = subtractTokenMaps(available, required);

    if (inputs.size === 0 || changeAda < 0n || hasNegativeAssetValue(changeAssets))
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);

    return {
      outputAssets: required,
      totalLovelaceInput: totalIn,
      totalLovelaceOutput: totalOut
    };
  }

  /**
   * Selects the largest UTxOs per required asset until each target amount is fulfilled.
   *
   * @param requiredAssets The asset quantities required by the transaction outputs.
   * @param allAvailable All available UTxOs (including preselected ones).
   * @param preSelected The UTxOs already selected for the transaction.
   * @returns A set of selected UTxOs covering the asset requirements.
   * @throws {InputSelectionError} If any asset cannot be sufficiently fulfilled.
   */
  #selectAssets(
    requiredAssets: Map<Cardano.AssetId, bigint>,
    allAvailable: Cardano.Utxo[],
    preSelected: Cardano.Utxo[]
  ): Set<Cardano.Utxo> {
    const selected = new Set(preSelected);

    for (const [assetId, requiredQuantity] of requiredAssets) {
      const candidates = allAvailable
        .filter(([_, out]) => (out.value.assets?.get(assetId) ?? 0n) > 0n)
        .sort(([, a], [, b]) => sortByAssetQuantity(assetId)(a, b));

      let accumulated = 0n;

      for (const candidate of candidates) {
        selected.add(candidate);
        accumulated += candidate[1].value.assets?.get(assetId) ?? 0n;
        if (accumulated >= requiredQuantity) break;
      }

      if (accumulated < requiredQuantity) throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }

    return selected;
  }

  /**
   * Selects UTxOs (largest Ada first) until the total Lovelace covers the target amount.
   *
   * @param target The required amount of Lovelace.
   * @param allAvailable All available UTxOs.
   * @param selected The current set of already selected UTxOs.
   * @param implicitCoinInput The implicit coin input amount.
   * @returns A new set including the original selected UTxOs plus any added for Ada coverage.
   * @throws {InputSelectionError} If the Lovelace requirement cannot be fulfilled.
   */
  #selectLovelace(
    target: bigint,
    allAvailable: Cardano.Utxo[],
    selected: Set<Cardano.Utxo>,
    implicitCoinInput: bigint
  ): Set<Cardano.Utxo> {
    const result = new Set(selected);
    const selectedTxIns = new Set([...selected].map(([txIn]) => txIn));

    const adaCandidates = allAvailable
      .filter(([txIn]) => !selectedTxIns.has(txIn))
      .sort(([, a], [, b]) => sortByCoins(a, b));

    let adaAccumulated = getCoinQuantity(toValues([...result])) + implicitCoinInput;

    for (const candidate of adaCandidates) {
      if (adaAccumulated >= target) break;
      result.add(candidate);
      adaAccumulated += candidate[1].value.coins;
    }

    if (result.size === 0) {
      if (adaCandidates.length === 0) throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
      result.add(adaCandidates[0]);
    }

    if (adaAccumulated < target) throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);

    return result;
  }

  /**
   * Computes the UTxOs that were not selected, given the original list and selected set.
   *
   * @param original The original list of available UTxOs (excluding preselected).
   * @param used The set of selected UTxOs.
   * @returns A new set of UTxOs that were not consumed in the transaction.
   */
  #computeRemainingUtxo(original: Cardano.Utxo[], used: Set<Cardano.Utxo>): Set<Cardano.Utxo> {
    const usedTxIns = new Set([...used].map(([txIn]) => txIn));
    return new Set(original.filter(([txIn]) => !usedTxIns.has(txIn)));
  }

  /**
   * Select additional UTxOs until the fee and min-Ada requirements are
   * satisfied, then build the final change outputs.
   *
   * @param initialInputs The UTxOs already chosen for assets and/or pre-selected by the wallet.
   * @param outputs The explicit transaction outputs.
   * @param allAvailable Every UTxO the wallet can spend (pre-selected ∪ utxo).
   * @param requiredAssets Aggregate asset requirements computed from `outputs` + burn.  Used for fee/Ada expansion.
   * @param constraints Network / wallet selection constraints (min-Ada, fee estimator, bundle size, limit…).
   * @param changeAddressResolver Callback that assigns addresses (or further splits) for the provisional change bundles returned by the fee engine.
   * @param implicitValue Optional implicit components (deposits, withdrawals, mint or burn)
   * @returns An object containing Set of all inputs that will appear in the tx body, minimum fee returned by the cost model and an Array of change outputs.
   */
  async #expandUtxosUntilFeeCovered(
    initialInputs: Set<Cardano.Utxo>,
    outputs: Set<Cardano.TxOut>,
    allAvailable: Cardano.Utxo[],
    requiredAssets: Cardano.TokenMap,
    constraints: SelectionConstraints,
    changeAddressResolver: ChangeAddressResolver,
    implicitValue?: ImplicitValue
  ): Promise<{ finalSelection: Set<Cardano.Utxo>; fee: bigint; change: Cardano.TxOut[] }> {
    const utxoSelectedArr = [...initialInputs];
    const utxoRemainingArr = allAvailable
      .filter((u) => !initialInputs.has(u))
      .sort(([, a], [, b]) => sortByCoins(a, b)); // Ada-descending

    const outputValues = toValues([...outputs]);

    const changeAddress = stubMaxSizeAddress;

    const implicitCoin: Required<Cardano.util.ImplicitCoin> = {
      deposit: implicitValue?.coin?.deposit || 0n,
      input: implicitValue?.coin?.input || 0n,
      reclaimDeposit: implicitValue?.coin?.reclaimDeposit || 0n,
      withdrawals: implicitValue?.coin?.withdrawals || 0n
    };
    const mintMap: Cardano.TokenMap = implicitValue?.mint || new Map();
    const uniqueTxAssetIDs = uniq([...requiredAssets.keys(), ...mintMap.keys()]);

    const { implicitTokensInput, implicitTokensSpend } = mintToImplicitTokens(mintMap);
    const implicitTokens: ImplicitTokens = {
      input: (assetId) => implicitTokensInput.get(assetId) || 0n,
      spend: (assetId) => implicitTokensSpend.get(assetId) || 0n
    };
    const {
      change,
      fee,
      inputs: finalInputs
    } = await computeChangeAndAdjustForFee({
      computeMinimumCoinQuantity: constraints.computeMinimumCoinQuantity,
      estimateTxCosts: (utxos, changeValues) =>
        constraints.computeMinimumCost({
          change: changeValues.map(
            (value) =>
              ({
                address: changeAddress,
                value
              } as Cardano.TxOut)
          ),
          fee: MAX_U64,
          inputs: new Set(utxos),
          outputs
        }),
      implicitValue: {
        implicitCoin,
        implicitTokens
      },
      outputValues,
      pickAdditionalUtxo: pickAdditionalLargestUtxo,
      tokenBundleSizeExceedsLimit: constraints.tokenBundleSizeExceedsLimit,
      uniqueTxAssetIDs,
      utxoSelection: {
        utxoRemaining: utxoRemainingArr,
        utxoSelected: utxoSelectedArr
      }
    });

    if (change.length === 0) {
      return {
        change: [],
        fee,
        finalSelection: new Set(finalInputs)
      };
    }

    const changeTxOuts: Cardano.TxOut[] = change.map((val) => ({
      address: changeAddress,
      value: val
    }));

    const resolvedChange = await changeAddressResolver.resolve({
      change: changeTxOuts,
      fee,
      inputs: new Set(finalInputs),
      outputs
    });

    return {
      change: resolvedChange,
      fee,
      finalSelection: new Set(finalInputs)
    };
  }
}
