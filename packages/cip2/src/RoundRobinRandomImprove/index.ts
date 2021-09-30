import { CardanoSerializationLib } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { maxBigNum } from '../util';
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

    const { change, inputs, remainingUTxO, fee } = await computeChangeAndAdjustForFee({
      csl,
      computeMinimumCoinQuantity,
      tokenBundleSizeExceedsLimit,
      outputValues,
      uniqueOutputAssetIDs,
      utxoSelection: roundRobinSelectionResult,
      estimateTxFee: (utxos, changeValues) =>
        computeMinimumCost({
          inputs: utxos,
          change: changeValues,
          fee: maxBigNum(csl),
          outputs
        })
    });

    const feeBigNum = csl.BigNum.from_str(fee.toString());
    if (inputs.length > (await computeSelectionLimit({ inputs, change, fee: feeBigNum, outputs }))) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    return {
      selection: {
        change,
        inputs,
        outputs,
        fee: feeBigNum
      },
      remainingUTxO
    };
  }
});
