import { Cardano, cmlUtil } from '@cardano-sdk/core';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { assertIsBalanceSufficient, preProcessArgs, toValues } from '../util';
import { computeChangeAndAdjustForFee } from './change';
import { roundRobinSelection } from './roundRobin';

interface RoundRobinRandomImproveOptions {
  getChangeAddress: () => Promise<Cardano.PaymentAddress>;
  random?: typeof Math.random;
}

export const roundRobinRandomImprove = ({
  getChangeAddress,
  random = Math.random
}: RoundRobinRandomImproveOptions): InputSelector => ({
  select: async ({
    utxo: utxoSet,
    outputs: outputSet,
    constraints: { computeMinimumCost, computeSelectionLimit, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit },
    implicitValue: partialImplicitValue = {}
  }: InputSelectionParameters): Promise<SelectionResult> => {
    const changeAddress = await getChangeAddress();
    const { utxo, outputs, uniqueTxAssetIDs, implicitValue } = preProcessArgs(
      utxoSet,
      outputSet,
      changeAddress,
      partialImplicitValue
    );

    assertIsBalanceSufficient(uniqueTxAssetIDs, utxo, outputs, implicitValue);

    const roundRobinSelectionResult = roundRobinSelection({
      changeAddress,
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
          change: changeValues.map(
            (value) =>
              ({
                address: changeAddress,
                value
              } as Cardano.TxOut)
          ),
          fee: cmlUtil.MAX_U64,
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
    const change = result.change.map((value) => ({
      address: changeAddress,
      value
    }));

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
