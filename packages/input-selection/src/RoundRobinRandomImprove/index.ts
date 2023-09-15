import { Cardano } from '@cardano-sdk/core';
import { ChangeAddressResolver } from '../ChangeAddress';
import { InputSelectionError, InputSelectionFailure } from '../InputSelectionError';
import { InputSelectionParameters, InputSelector, SelectionResult } from '../types';
import { assertIsBalanceSufficient, preProcessArgs, stubMaxSizeAddress, toValues } from '../util';
import { computeChangeAndAdjustForFee } from './change';
import { roundRobinSelection } from './roundRobin';

export const MAX_U64 = 18_446_744_073_709_551_615n;

interface RoundRobinRandomImproveOptions {
  changeAddressResolver: ChangeAddressResolver;
  random?: typeof Math.random;
}

export const roundRobinRandomImprove = ({
  changeAddressResolver,
  random = Math.random
}: RoundRobinRandomImproveOptions): InputSelector => ({
  select: async ({
    utxo: utxoSet,
    outputs: outputSet,
    constraints: { computeMinimumCost, computeSelectionLimit, computeMinimumCoinQuantity, tokenBundleSizeExceedsLimit },
    implicitValue: partialImplicitValue = {}
  }: InputSelectionParameters): Promise<SelectionResult> => {
    const changeAddress = stubMaxSizeAddress;
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
          fee: MAX_U64,
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

    const selection = {
      change: result.change.map((value) => ({
        address: changeAddress,
        value
      })),
      fee: result.fee,
      inputs,
      outputs: outputSet
    };

    selection.change = await changeAddressResolver.resolve(selection);

    if (
      result.inputs.length >
      (await computeSelectionLimit({ change: selection.change, fee: selection.fee, inputs, outputs: outputSet }))
    ) {
      throw new InputSelectionError(InputSelectionFailure.MaximumInputCountExceeded);
    }

    return {
      remainingUTxO: new Set(result.remainingUTxO),
      selection
    };
  }
});
