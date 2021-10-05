import { CardanoSerializationLib, cslUtil } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { computeChangeAndAdjustForFee } from './change';
import { roundRobinSelection } from './roundRobin';
import { assertIsBalanceSufficient, preprocessArgs, withValuesToValues } from './util';

export const roundRobinRandomImprove = (csl: CardanoSerializationLib): InputSelector => ({
  select: async ({
    utxo,
    outputs,
    constraints: { computeMinimumCost, computeSelectionLimit, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit }
  }: InputSelectionParameters): Promise<SelectionResult> => {
    const { uniqueOutputAssetIDs, utxosWithValue, outputsWithValue } = preprocessArgs(utxo, outputs);

    const utxoValues = withValuesToValues(utxosWithValue);
    const outputValues = withValuesToValues(outputsWithValue);
    assertIsBalanceSufficient(uniqueOutputAssetIDs, utxoValues, outputValues);

    const roundRobinSelectionResult = roundRobinSelection(utxosWithValue, outputsWithValue, uniqueOutputAssetIDs);

    const result = await computeChangeAndAdjustForFee({
      csl,
      computeMinimumCoinQuantity,
      tokenBundleSizeExceedsLimit,
      outputValues,
      uniqueOutputAssetIDs,
      utxoSelection: roundRobinSelectionResult,
      estimateTxFee: (utxos, changeValues) =>
        computeMinimumCost({
          inputs: new Set(utxos),
          change: new Set(changeValues),
          fee: cslUtil.maxBigNum(csl),
          outputs
        })
    });

    const inputs = new Set(result.inputs);
    const change = new Set(result.change);
    const fee = csl.BigNum.from_str(result.fee.toString());

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
