import { CardanoSerializationLib } from '@cardano-sdk/cardano-serialization-lib';
import { Cardano } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { createCslUtils, transactionOutputsToArray } from '../util';
import { computeChangeAndAdjustForFee } from './change';
import { roundRobinSelection } from './roundRobin';
import { assertIsBalanceSufficient, preprocessArgs } from './util';

export const roundRobinRandomImprove = (CSL: CardanoSerializationLib, coinsPerUtxoWord: bigint): InputSelector => {
  const minUtxoCoinValue = Cardano.util.computeMinUtxoValue(coinsPerUtxoWord);
  const cslUtils = createCslUtils(CSL);

  return {
    select: async ({
      utxo,
      outputs,
      estimateTxFee,
      maximumInputCount
    }: InputSelectionParameters): Promise<SelectionResult> => {
      const outputsArray = transactionOutputsToArray(outputs);
      if (outputsArray.length === 0) {
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

      const { uniqueOutputAssetIDs, utxoWithTotals, outputsWithTotals } = preprocessArgs(cslUtils, utxo, outputsArray);
      assertIsBalanceSufficient(uniqueOutputAssetIDs, utxoWithTotals, outputsWithTotals);

      const roundRobinSelectionResult = roundRobinSelection(utxoWithTotals, outputsWithTotals, uniqueOutputAssetIDs);
      const { change, inputs, remainingUTxO, fee } = await computeChangeAndAdjustForFee({
        cslUtils,
        minUtxoCoinValue,
        outputsWithTotals,
        uniqueOutputAssetIDs,
        utxoSelection: roundRobinSelectionResult,
        estimateTxFee: (utxos, changeValues) => estimateTxFee(utxos, outputs, changeValues)
      });

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
  };
};
