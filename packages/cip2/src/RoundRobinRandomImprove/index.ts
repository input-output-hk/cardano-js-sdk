import { cslUtil, CSL } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { computeChangeAndAdjustForFee } from './change';
import { roundRobinSelection } from './roundRobin';
import { assertIsBalanceSufficient, preprocessArgs, withValuesToValues } from './util';

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
      utxosWithValue,
      uniqueOutputAssetIDs
    });

    const result = await computeChangeAndAdjustForFee({
      computeMinimumCoinQuantity,
      tokenBundleSizeExceedsLimit,
      outputValues,
      uniqueOutputAssetIDs,
      implicitCoin,
      utxoSelection: roundRobinSelectionResult,
      estimateTxFee: (utxos, changeValues) =>
        computeMinimumCost({
          inputs: new Set(utxos),
          change: new Set(changeValues),
          fee: cslUtil.maxBigNum,
          outputs
        })
    });

    const inputs = new Set(result.inputs);
    const change = new Set(result.change);
    const fee = CSL.BigNum.from_str(result.fee.toString());

    if (result.inputs.length > (await computeSelectionLimit({ inputs, change, fee, outputs }))) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    return {
      selection: {
        change,
        inputs,
        outputs,
        fee
      },
      remainingUTxO: new Set(result.remainingUTxO)
    };
  }
});
