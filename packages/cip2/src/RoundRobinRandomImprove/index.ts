import { CardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { transactionOutputsToArray } from '../util';
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
          fee: await computeMinimumCost({
            change: [],
            utxo,
            outputs
          }),
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
          utxo: utxos,
          change: changeValues,
          outputs
        })
    });

    if (inputs.length > (await computeSelectionLimit({ utxo: inputs, change, outputs }))) {
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
});
