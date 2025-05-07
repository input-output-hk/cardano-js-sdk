import { Cardano } from '@cardano-sdk/core';
import { ChangeAddressResolver } from '../ChangeAddress';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import {
  MAX_U64,
  UtxoSelection,
  assertIsBalanceSufficient,
  preProcessArgs,
  sortUtxoByTxIn,
  stubMaxSizeAddress,
  toValues
} from '../util';
import { PickAdditionalUtxo, computeChangeAndAdjustForFee } from '../change';
import { roundRobinSelection } from './roundRobin';

interface RoundRobinRandomImproveOptions {
  changeAddressResolver: ChangeAddressResolver;
  random?: typeof Math.random;
}

/** Picks one UTxO from remaining set and puts it to the selected set. Precondition: utxoRemaining.length > 0 */
export const createPickAdditionalRandomUtxo =
  (random: typeof Math.random): PickAdditionalUtxo =>
  ({ utxoRemaining, utxoSelected }: UtxoSelection): UtxoSelection => {
    const remainingUtxoOfOnlyCoin = utxoRemaining.filter(([_, { value }]) => !value.assets);
    const pickFrom = remainingUtxoOfOnlyCoin.length > 0 ? remainingUtxoOfOnlyCoin : utxoRemaining;
    const pickIdx = Math.floor(random() * pickFrom.length);
    const newUtxoSelected = [...utxoSelected, pickFrom[pickIdx]];
    const originalIdx = utxoRemaining.indexOf(pickFrom[pickIdx]);
    const newUtxoRemaining = [...utxoRemaining.slice(0, originalIdx), ...utxoRemaining.slice(originalIdx + 1)];
    return { utxoRemaining: newUtxoRemaining, utxoSelected: newUtxoSelected };
  };

export const roundRobinRandomImprove = ({
  changeAddressResolver,
  random = Math.random
}: RoundRobinRandomImproveOptions): InputSelector => ({
  select: async ({
    preSelectedUtxo: preSelectedUtxoSet,
    utxo: utxoSet,
    outputs: outputSet,
    constraints: { computeMinimumCost, computeSelectionLimit, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit },
    implicitValue: partialImplicitValue = {}
  }: InputSelectionParameters): Promise<SelectionResult> => {
    const changeAddress = stubMaxSizeAddress;
    const { requiredUtxo, utxo, outputs, uniqueTxAssetIDs, implicitValue } = preProcessArgs(
      preSelectedUtxoSet,
      utxoSet,
      outputSet,
      changeAddress,
      partialImplicitValue
    );

    assertIsBalanceSufficient(uniqueTxAssetIDs, requiredUtxo, utxo, outputs, implicitValue);

    const roundRobinSelectionResult = roundRobinSelection({
      changeAddress,
      implicitValue,
      outputs,
      random,
      requiredUtxo,
      uniqueTxAssetIDs,
      utxo
    });

    const result = await computeChangeAndAdjustForFee({
      computeMinimumCoinQuantity,
      estimateTxCosts: (utxos, changeValues) =>
        computeMinimumCost({
          change: changeValues.map(
            (value) =>
              ({
                address: changeAddress,
                value
              } as Cardano.TxOut)
          ),
          fee: MAX_U64,
          inputs: new Set(utxos),
          outputs: outputSet
        }),
      implicitValue,
      outputValues: toValues(outputs),
      pickAdditionalUtxo: createPickAdditionalRandomUtxo(random),
      tokenBundleSizeExceedsLimit,
      uniqueTxAssetIDs,
      utxoSelection: roundRobinSelectionResult
    });

    const inputs = new Set(result.inputs);

    const selection = {
      change: result.change.map((value) => ({
        address: changeAddress,
        value
      })),
      fee: result.fee,
      inputs,
      outputs: outputSet
    };

    selection.change = await changeAddressResolver.resolve(selection);

    if (
      result.inputs.length >
      (await computeSelectionLimit({ change: selection.change, fee: selection.fee, inputs, outputs: outputSet }))
    ) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    selection.inputs = new Set([...selection.inputs].sort(sortUtxoByTxIn));

    return {
      redeemers: result.redeemers,
      remainingUTxO: new Set(result.remainingUTxO),
      selection
    };
  }
});
