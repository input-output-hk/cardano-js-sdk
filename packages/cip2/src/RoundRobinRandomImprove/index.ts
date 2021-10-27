import { CSL, cslUtil } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { assertIsBalanceSufficient, preprocessArgs, withValuesToValues } from './util';
import { computeChangeAndAdjustForFee } from './change';
import { roundRobinSelection } from './roundRobin';

export const roundRobinRandomImprove = (): InputSelector => ({
  select: async ({
    utxo,
    outputs,
    constraints: { computeMinimumCost, computeSelectionLimit, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit },
    implicitCoin: implicitCoinAsNumber
  }: InputSelectionParameters): Promise<SelectionResult> => {
    const { utxosWithValue, outputsWithValue, uniqueOutputAssetIDs, implicitCoin } = preprocessArgs(
      utxo,
      outputs,
      implicitCoinAsNumber
    );

    const utxoValues = withValuesToValues(utxosWithValue);
    const outputValues = withValuesToValues(outputsWithValue);
    assertIsBalanceSufficient(uniqueOutputAssetIDs, utxoValues, outputValues, implicitCoin);

    const roundRobinSelectionResult = roundRobinSelection({
      implicitCoin,
      outputsWithValue,
      uniqueOutputAssetIDs,
      utxosWithValue
    });

    const result = await computeChangeAndAdjustForFee({
      computeMinimumCoinQuantity,
      estimateTxFee: (utxos, changeValues) =>
        computeMinimumCost({
          change: new Set(changeValues),
          fee: cslUtil.maxBigNum,
          inputs: new Set(utxos),
          outputs
        }),
      implicitCoin,
      outputValues,
      tokenBundleSizeExceedsLimit,
      uniqueOutputAssetIDs,
      utxoSelection: roundRobinSelectionResult
    });

    const inputs = new Set(result.inputs);
    const change = new Set(result.change);
    const fee = CSL.BigNum.from_str(result.fee.toString());

    if (result.inputs.length > (await computeSelectionLimit({ change, fee, inputs, outputs }))) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    return {
      remainingUTxO: new Set(result.remainingUTxO),
      selection: {
        change,
        fee,
        inputs,
        outputs
      }
    };
  }
});
