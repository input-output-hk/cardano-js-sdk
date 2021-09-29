import { CardanoSerializationLib } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { maxBigNum, transactionOutputsToArray } from '../util';
import { computeChangeAndAdjustForFee } from './change';
import { roundRobinSelection } from './roundRobin';
import { assertIsBalanceSufficient, preprocessArgs } from './util';

export const roundRobinRandomImprove = (csl: CardanoSerializationLib): InputSelector => ({
  select: async ({
    utxo,
    outputs,
    constraints: { computeMinimumCost, computeSelectionLimit, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit }
  }: InputSelectionParameters): Promise<SelectionResult> => {
    const outputsArray = transactionOutputsToArray(outputs);
    if (outputsArray.length === 0) {
      return {
        remainingUTxO: utxo,
        selection: {
          inputs: [],
          fee: csl.BigNum.from_str(
            (
              await computeMinimumCost({
                change: [],
                inputs: utxo,
                fee: maxBigNum(csl),
                outputs
              })
            ).toString()
          ),
          change: [],
          outputs
        }
      };
    }

    const { uniqueOutputAssetIDs, utxoWithTotals, outputsWithTotals } = preprocessArgs(utxo, outputsArray);
    assertIsBalanceSufficient(uniqueOutputAssetIDs, utxoWithTotals, outputsWithTotals);

    const roundRobinSelectionResult = roundRobinSelection(utxoWithTotals, outputsWithTotals, uniqueOutputAssetIDs);

    const { change, inputs, remainingUTxO, fee } = await computeChangeAndAdjustForFee({
      csl,
      computeMinimumCoinQuantity,
      tokenBundleSizeExceedsLimit,
      outputsWithTotals,
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

    if (inputs.length > (await computeSelectionLimit({ inputs, change, fee: maxBigNum(csl), outputs }))) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    return {
      selection: {
        change,
        inputs,
        outputs,
        fee: csl.BigNum.from_str(fee.toString())
      },
      remainingUTxO
    };
  }
});
