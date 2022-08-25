import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { assertIsBalanceSufficient, preProcessArgs, toValues } from './util';
import { computeChangeAndAdjustForFee } from './change';
import { cslUtil } from '@cardano-sdk/core';
import { roundRobinSelection } from './roundRobin';

interface RoundRobinRandomImproveOptions {
  random?: typeof Math.random;
}

export const roundRobinRandomImprove = ({
  random = Math.random
}: RoundRobinRandomImproveOptions = {}): InputSelector => ({
  select: async ({
    utxo: utxoSet,
    outputs: outputSet,
    constraints: { computeMinimumCost, computeSelectionLimit, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit },
    implicitValue: partialImplicitValue = {}
  }: InputSelectionParameters): Promise<SelectionResult> => {
    const { utxo, outputs, uniqueTxAssetIDs, implicitValue } = preProcessArgs(utxoSet, outputSet, partialImplicitValue);

    assertIsBalanceSufficient(uniqueTxAssetIDs, utxo, outputs, implicitValue);

    const roundRobinSelectionResult = roundRobinSelection({
      implicitValue,
      outputs,
      random,
      uniqueTxAssetIDs,
      utxo
    });

    const result = await computeChangeAndAdjustForFee({
      computeMinimumCoinQuantity,
      estimateTxFee: (utxos, changeValues) =>
        computeMinimumCost({
          change: new Set(changeValues),
          fee: cslUtil.MAX_U64,
          inputs: new Set(utxos),
          outputs: outputSet
        }),
      implicitValue,
      outputValues: toValues(outputs),
      random,
      tokenBundleSizeExceedsLimit,
      uniqueTxAssetIDs,
      utxoSelection: roundRobinSelectionResult
    });

    const inputs = new Set(result.inputs);
    const change = new Set(result.change);

    if (result.inputs.length > (await computeSelectionLimit({ change, fee: result.fee, inputs, outputs: outputSet }))) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    return {
      remainingUTxO: new Set(result.remainingUTxO),
      selection: {
        change,
        fee: result.fee,
        inputs,
        outputs: outputSet
      }
    };
  }
});
