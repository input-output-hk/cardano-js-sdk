// Review: this is a pretty big file, but code is pretty specific to this algorithm implemenation
// as it considers output quantities collectively. If filesize is a problem, we could:
// a) Split it into 3 files: this class, round-robin selection and change computation
// b) Find things that look generic, e.g. assertIsBalanceSufficient could be used by any input selection algorithm
import { TransactionOutput, TransactionUnspentOutput, Value } from '@emurgo/cardano-serialization-lib-browser';
import { CardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { uniq, orderBy, sum } from 'lodash-es';
import { InputSelector, SelectionResult, InputSelectionParameters } from './types';
import { InputSelectionError, InputSelectionFailure } from './InputSelectionError';
import {
  AssetQuantities,
  ValueQuantities,
  bigintSum,
  bigintAbs,
  coalesceValueQuantities,
  createCslUtils,
  CslUtils,
  transactionOutputsToArray,
  computeMinUtxoValue
} from './util';

interface Totals {
  totals: ValueQuantities;
}

interface UtxoWithTotals extends Totals {
  utxo: TransactionUnspentOutput;
}

interface OutputWithTotals extends Totals {
  output: TransactionOutput;
}

interface UtxoSelection {
  utxoSelected: UtxoWithTotals[];
  utxoRemaining: UtxoWithTotals[];
}

interface ChangeComputationResult {
  remainingUTxO: TransactionUnspentOutput[];
  inputs: TransactionUnspentOutput[];
  change: Value[];
  fee: bigint;
}

type EstimateTxFeeWithOriginalOutputs = (utxo: TransactionUnspentOutput[], change: Value[]) => Promise<bigint>;

const assetQuantitySelector = (id: string) => (totals: Totals[]) =>
  bigintSum(totals.map(({ totals: { assets } }) => assets?.[id] || 0n));
const getCoinQuantity = (totals: Totals[]) => bigintSum(totals.map(({ totals: { coins } }) => coins));

/**
 * RoundRobinRandomImprove algorithm implementation for Input Selection.
 */
export class RoundRobinRandomImprove implements InputSelector {
  private readonly cslUtils: CslUtils;
  private readonly minUtxoCoinValue: bigint;

  /**
   * Set up Random Improve algorithm that
   * operates with specified protocol parameters.
   */
  constructor(coinsPerUtxoWord: bigint, CSL: CardanoSerializationLib) {
    this.minUtxoCoinValue = computeMinUtxoValue(coinsPerUtxoWord);
    this.cslUtils = createCslUtils(CSL);
  }

  public async select({
    utxo,
    outputs,
    estimateTxFee,
    maximumInputCount
  }: InputSelectionParameters): Promise<SelectionResult> {
    const outputsArray = transactionOutputsToArray(outputs);
    if (outputsArray.length === 0) {
      // Review: on a 2nd thought I think this is better than throwing an error.
      // We might need to support it in the future as in ADP-1136,
      // and without this exception I don't think there's a need to validate other params,
      // so we can get away with keeping only errors that correspond to spec-defined Failure Modes
      return {
        remainingUTxO: utxo,
        selection: {
          inputs: [],
          fee: await estimateTxFee([], outputs, []),
          change: [],
          outputs
        }
      };
    }

    const { uniqueOutputAssetIDs, utxoWithTotals, outputsWithTotals } = this.preprocessArgs(utxo, outputsArray);
    this.assertIsBalanceSufficient(uniqueOutputAssetIDs, utxoWithTotals, outputsWithTotals);

    const roundRobinSelectionResult = this.roundRobinSelection(utxoWithTotals, outputsWithTotals, uniqueOutputAssetIDs);
    const { change, inputs, remainingUTxO, fee } = await this.computeChangeAndAdjustForFee(
      roundRobinSelectionResult,
      outputsWithTotals,
      uniqueOutputAssetIDs,
      (utxos, changeValues) => estimateTxFee(utxos, outputs, changeValues)
    );

    if (inputs.length > maximumInputCount) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    return {
      selection: {
        change,
        inputs,
        outputs,
        fee
      },
      remainingUTxO
    };
  }

  /**
   * Round-Robin selection algorithm.
   *
   * Assumes we have already checked that the available UTxO balance is sufficient to cover all tokens in the outputs.
   * Considers all outputs collectively, as a combined output bundle.
   *
   * @throws InputSelectionError (UtxoBalanceInsufficient)
   */
  private roundRobinSelection(
    availableUtxo: UtxoWithTotals[],
    outputs: OutputWithTotals[],
    uniqueOutputAssetIDs: string[]
  ): UtxoSelection {
    // The subset of the UTxO that has already been selected:
    const utxoSelected: UtxoWithTotals[] = [];
    // The subset of the UTxO that remains available for selection:
    const utxoRemaining = [...availableUtxo];
    // The set of tokens that we still need to cover:
    const tokensRemaining = this.listTokensWithin(uniqueOutputAssetIDs, outputs);
    while (tokensRemaining.length > 0) {
      // Consider each token in round-robin fashion:
      for (const [tokenIdx, { filterUtxo, minimumTarget, getQuantity }] of tokensRemaining.entries()) {
        // Attempt to select at random an input that includes
        // this token from the remaining UTxO set:
        const utxo = filterUtxo(utxoRemaining);
        if (utxo.length > 0) {
          const inputIdx = Math.floor(Math.random() * utxo.length);
          const input = utxo[inputIdx];
          if (this.improvesSelection(utxoSelected, input, minimumTarget, getQuantity)) {
            utxoSelected.push(input);
            utxoRemaining.splice(utxoRemaining.indexOf(input), 1);
          } else {
            // The selection was not improved by including
            // this input. If we've reached this point, it
            // means that we've already covered the minimum
            // target of 100%, and therefore it is safe to
            // not consider this token any further.
            tokensRemaining.splice(tokenIdx, 1);
          }
        } else {
          // The attempt to select an input failed (there were
          // no inputs remaining that contained the token).
          // This means that we've already covered the minimum
          // quantity required (due to the pre-condition), and
          // therefore it is safe to not consider this token
          // any further:
          tokensRemaining.splice(tokenIdx, 1);
        }
      }
    }
    return { utxoSelected, utxoRemaining };
  }

  private improvesSelection(
    utxoAlreadySelected: UtxoWithTotals[],
    input: UtxoWithTotals,
    minimumTarget: bigint,
    getQuantity: (totals: Totals[]) => bigint
  ) {
    const oldQuantity = getQuantity(utxoAlreadySelected);
    // We still haven't reached the minimum target of
    // 100%. Therefore, we consider any potential input
    // to be an improvement:
    if (oldQuantity < minimumTarget) return true;
    const newQuantity = oldQuantity + getQuantity([input]);
    const idealTarget = 2n * minimumTarget;
    const newDistance = bigintAbs(idealTarget - newQuantity);
    const oldDistance = bigintAbs(idealTarget - oldQuantity);
    // Using this input will move us closer to the
    // ideal target of 200%, so we treat this as an improvement:
    if (newDistance < oldDistance) return true;
    // Adding the selected input would move us further
    // away from the target of 200%. Reaching this case
    // means we have already covered the minimum target
    // of 100%, and therefore it is safe to not consider
    // this token any further:
    return false;
  }

  private listTokensWithin(uniqueOutputAssetIDs: string[], outputs: OutputWithTotals[]) {
    return [
      ...uniqueOutputAssetIDs.map((id) => {
        const getQuantity = assetQuantitySelector(id);
        return {
          getQuantity,
          minimumTarget: getQuantity(outputs),
          filterUtxo: (utxo: UtxoWithTotals[]) => utxo.filter(({ totals: { assets } }) => assets?.[id])
        };
      }),
      {
        // ADA
        getQuantity: (totals: Totals[]) => getCoinQuantity(totals),
        minimumTarget: getCoinQuantity(outputs),
        filterUtxo: (utxo: UtxoWithTotals[]) => utxo
      }
    ];
  }

  /**
   * Picks one UTxO from remaining set and puts it to the selected set.
   * Precondition: utxoRemaining.length > 0
   */
  private pickExtraRandomUtxo({ utxoRemaining, utxoSelected }: UtxoSelection): UtxoSelection {
    const pickIdx = Math.floor(Math.random() * utxoRemaining.length);
    const newUtxoSelected = [...utxoSelected, utxoRemaining[pickIdx]];
    const newUtxoRemaining = [...utxoRemaining.slice(0, pickIdx), ...utxoRemaining.slice(pickIdx + 1)];
    return { utxoSelected: newUtxoSelected, utxoRemaining: newUtxoRemaining };
  }

  private computeChangeBundles(
    utxoSelection: UtxoSelection,
    outputsWithTotals: OutputWithTotals[],
    uniqueOutputAssetIDs: string[]
  ): UtxoSelection & { changeBundles: ValueQuantities[] } {
    const requestedAssetChangeBundles = this.requestedAssetChangeBundles(
      utxoSelection.utxoSelected,
      outputsWithTotals,
      uniqueOutputAssetIDs
    );
    const requestedAssetChangeBundlesWithLeftoverAssets = this.redistributeLeftoverAssets(
      utxoSelection.utxoSelected,
      requestedAssetChangeBundles,
      uniqueOutputAssetIDs
    );
    const changeBundles = this.coalesceChangeBundlesForMinAdaRequirement(requestedAssetChangeBundlesWithLeftoverAssets);
    if (!changeBundles) {
      // Coalesced all bundles to 1 and it's still less than min utxo value
      if (utxoSelection.utxoRemaining.length > 0) {
        return this.computeChangeBundles(
          this.pickExtraRandomUtxo(utxoSelection),
          outputsWithTotals,
          uniqueOutputAssetIDs
        );
      }
      // Review: this is not a great error type for this, because the spec says
      // "due to various restrictions that coin selection algorithms impose on themselves when selecting UTxO entries."
      // And this happens due to blockchain restriction on minimum utxo coin quantity,
      // not due to the algorithm restriction.
      throw new InputSelectionError(InputSelectionFailure.UtxoFullyDepleted);
    }
    return { changeBundles, ...utxoSelection };
  }

  /**
   * 1. Compute change bundles.
   * 2. Compute fee and verify that change coin covers it. If not, select an additional UTxO and retry.
   *
   * @throws InputSelectionError { UtxoFullyDepleted, UtxoBalanceInsufficient }
   */
  private async computeChangeAndAdjustForFee(
    utxoSelection: UtxoSelection,
    outputsWithTotals: OutputWithTotals[],
    uniqueOutputAssetIDs: string[],
    estimateTxFee: EstimateTxFeeWithOriginalOutputs
  ): Promise<ChangeComputationResult> {
    const {
      changeBundles: finalChangeBundles,
      utxoSelected,
      utxoRemaining
    } = this.computeChangeBundles(utxoSelection, outputsWithTotals, uniqueOutputAssetIDs);

    const change = finalChangeBundles.map((bundle) => this.cslUtils.valueQuantitiesToValue(bundle));

    const fee = await estimateTxFee(
      utxoSelected.map(({ utxo }) => utxo),
      change
    );

    if (getCoinQuantity(finalChangeBundles.map((totals) => ({ totals }))) < fee) {
      if (utxoRemaining.length === 0) {
        throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
      }
      // Recompute change and fee with an extra selected UTxO
      return this.computeChangeAndAdjustForFee(
        this.pickExtraRandomUtxo({ utxoSelected, utxoRemaining }),
        outputsWithTotals,
        uniqueOutputAssetIDs,
        estimateTxFee
      );
    }
    return {
      remainingUTxO: utxoRemaining.map(({ utxo }) => utxo),
      inputs: utxoSelected.map(({ utxo }) => utxo),
      change,
      fee
    };
  }

  private coalesceChangeBundlesForMinAdaRequirement(changeBundles: ValueQuantities[]): ValueQuantities[] | undefined {
    if (changeBundles.length === 0) {
      return changeBundles;
    }
    const sortedBundles = orderBy(changeBundles, ({ coins }) => coins, 'desc');
    while (sortedBundles.length > 1 && sortedBundles[sortedBundles.length - 1].coins < this.minUtxoCoinValue) {
      const smallestBundle = sortedBundles.pop();
      sortedBundles[sortedBundles.length - 1] = coalesceValueQuantities(
        sortedBundles[sortedBundles.length - 1],
        smallestBundle
      );
    }
    if (sortedBundles[0].coins < this.minUtxoCoinValue) {
      // Coalesced all bundles to 1 and it's still less than min utxo value
      // eslint-disable-next-line consistent-return
      return undefined;
    }
    return sortedBundles;
  }

  /**
   * Redistribute additionally-selected tokens not present in the original outputs to the change bundles, where:
   * - if there are fewer quantities for a given token than the number of change bundles,
   *   include these quantities without changing them.
   * - if there are more quantities for a given token than the number of change bundles,
   *   coalesce the smallest quantities together.
   */
  private redistributeLeftoverAssets(
    utxoSelected: UtxoWithTotals[],
    requestedAssetChangeBundles: ValueQuantities[],
    uniqueOutputAssetIDs: string[]
  ) {
    const leftovers = this.getLeftoverAssets(utxoSelected, uniqueOutputAssetIDs);
    // Distribute leftovers to result bundles
    const resultBundles = [...requestedAssetChangeBundles];
    for (const id of Object.keys(leftovers)) {
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
  }

  private getLeftoverAssets(utxoSelected: UtxoWithTotals[], uniqueOutputAssetIDs: string[]) {
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
  }

  /**
   * Divide any excess token quantities (inputs − outputs) into change bundles, where:
   * - there is exactly one change bundle for each output.
   * - the quantity of a given token in a change bundle
   *   is proportional to the quantity of that token in the corresponding output.
   * - the total quantity of a given token across all change bundles
   *   is equal to the total excess quantity of that token.
   */
  private requestedAssetChangeBundles(
    utxoSelected: UtxoWithTotals[],
    outputsWithTotals: OutputWithTotals[],
    uniqueOutputAssetIDs: string[]
  ): ValueQuantities[] {
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

    const { totalCoinBundled, bundles, totalAssetsBundled } = this.createBundlePerOutput(
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
  }

  private createBundlePerOutput(
    outputsWithTotals: OutputWithTotals[],
    coinTotalRequested: bigint,
    coinChangeTotal: bigint,
    assetTotals: Record<string, { selected: bigint; requested: bigint }>
  ) {
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
  }

  private preprocessArgs(availableUtxo: TransactionUnspentOutput[], outputs: TransactionOutput[]) {
    const utxoWithTotals = availableUtxo.map((utxo) => ({
      utxo,
      totals: this.cslUtils.valueToValueQuantities(utxo.output().amount())
    }));
    const outputsWithTotals = outputs.map((output) => ({
      output,
      totals: this.cslUtils.valueToValueQuantities(output.amount())
    }));
    const uniqueOutputAssetIDs = uniq(
      outputsWithTotals.flatMap(({ totals: { assets } }) => (assets && Object.keys(assets)) || [])
    );
    return { uniqueOutputAssetIDs, utxoWithTotals, outputsWithTotals };
  }

  /**
   * Asserts that available balance of coin and assets
   * is sufficient to cover output quantities.
   *
   * @throws InputSelectionError { UtxoBalanceInsufficient }
   */
  private assertIsBalanceSufficient(
    uniqueOutputAssetIDs: string[],
    utxoWithTotals: UtxoWithTotals[],
    outputsWithTotals: OutputWithTotals[]
  ) {
    for (const id of uniqueOutputAssetIDs) {
      const getAssetQuantity = assetQuantitySelector(id);
      const utxoTotal = getAssetQuantity(utxoWithTotals);
      const outputsTotal = getAssetQuantity(outputsWithTotals);
      if (outputsTotal > utxoTotal) {
        throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
      }
    }
    const utxoCoinTotal = sum(utxoWithTotals.map(({ totals: { coins } }) => coins));
    const outputsCoinTotal = sum(outputsWithTotals.map(({ totals: { coins } }) => coins));
    if (outputsCoinTotal > utxoCoinTotal) {
      throw new InputSelectionError(InputSelectionFailure.UtxoBalanceInsufficient);
    }
  }
}
