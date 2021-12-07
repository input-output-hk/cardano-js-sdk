import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { assertIsBalanceSufficient, preprocessArgs, toValues } from './util';
import { computeChangeAndAdjustForFee } from './change';
import { cslUtil } from '@cardano-sdk/core';
import { roundRobinSelection } from './roundRobin';

export const roundRobinRandomImprove = (): InputSelector => ({
  select: async ({
    utxo: utxoSet,
    outputs: outputSet,
    constraints: { computeMinimumCost, computeSelectionLimit, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit },
    implicitCoin: implicitCoinAsNumber
  }: InputSelectionParameters): Promise<SelectionResult> => {
    const { utxo, outputs, uniqueOutputAssetIDs, implicitCoin } = preprocessArgs(
      utxoSet,
      outputSet,
      implicitCoinAsNumber
    );

    assertIsBalanceSufficient(uniqueOutputAssetIDs, utxo, outputs, implicitCoin);

    const roundRobinSelectionResult = roundRobinSelection({
      implicitCoin,
      outputs,
      uniqueOutputAssetIDs,
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
      implicitCoin,
      outputValues: toValues(outputs),
      tokenBundleSizeExceedsLimit,
      uniqueOutputAssetIDs,
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
