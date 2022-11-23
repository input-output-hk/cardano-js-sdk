import { CML, InvalidProtocolParametersError, cmlUtil, coreToCml } from '@cardano-sdk/core';
import {
  ComputeMinimumCoinQuantity,
  ComputeSelectionLimit,
  EstimateTxFee,
  ProtocolParametersForInputSelection,
  SelectionConstraints,
  SelectionSkeleton,
  TokenBundleSizeExceedsLimit
} from './types';
import { ProtocolParametersRequiredByInputSelection } from '.';
import { usingAutoFree } from '@cardano-sdk/util';

export type BuildTx = (selection: SelectionSkeleton) => Promise<CML.Transaction>;

export interface DefaultSelectionConstraintsProps {
  protocolParameters: ProtocolParametersForInputSelection;
  buildTx: BuildTx;
}

export const computeMinimumCost =
  (
    {
      minFeeCoefficient,
      minFeeConstant
    }: Pick<ProtocolParametersRequiredByInputSelection, 'minFeeCoefficient' | 'minFeeConstant'>,
    buildTx: BuildTx
  ): EstimateTxFee =>
  async (selection) => {
    const tx = await buildTx(selection);

    return usingAutoFree((scope) => {
      // TODO: Get this from cardano-services
      const priceMem = scope.manage(
        CML.UnitInterval.new(scope.manage(CML.BigNum.from_str('577')), scope.manage(CML.BigNum.from_str('10000')))
      );
      const priceStep = scope.manage(
        CML.UnitInterval.new(scope.manage(CML.BigNum.from_str('721')), scope.manage(CML.BigNum.from_str('100000000')))
      );
      const exInitPrices = scope.manage(CML.ExUnitPrices.new(priceMem, priceStep));

      const linearFee = scope.manage(
        CML.LinearFee.new(
          scope.manage(CML.BigNum.from_str(minFeeCoefficient.toString())),
          scope.manage(CML.BigNum.from_str(minFeeConstant.toString()))
        )
      );
      const minFee = scope.manage(CML.min_fee(tx, linearFee, exInitPrices));
      return BigInt(minFee.to_str());
    });
  };

export const computeMinimumCoinQuantity =
  (coinsPerUtxoByte: ProtocolParametersRequiredByInputSelection['coinsPerUtxoByte']): ComputeMinimumCoinQuantity =>
  (output) =>
    usingAutoFree((scope) =>
      BigInt(
        scope
          .manage(
            CML.min_ada_required(
              coreToCml.txOut(scope, output),
              scope.manage(CML.BigNum.from_str(coinsPerUtxoByte.toString()))
            )
          )
          .to_str()
      )
    );

export const tokenBundleSizeExceedsLimit =
  (maxValueSize: ProtocolParametersRequiredByInputSelection['maxValueSize']): TokenBundleSizeExceedsLimit =>
  (tokenBundle) => {
    if (!tokenBundle) {
      return false;
    }
    return usingAutoFree((scope) => {
      const value = scope.manage(CML.Value.new(cmlUtil.maxBigNum));
      value.set_multiasset(coreToCml.tokenMap(scope, tokenBundle));

      return value.to_bytes().length > maxValueSize;
    });
  };

const getTxSize = (tx: CML.Transaction) => tx.to_bytes().length;

/**
 * This constraint implementation is not intended to used by selection algorithms
 * that adjust selection based on selection limit. RRRI implementation uses this after selecting all the inputs
 * and throws MaximumInputCountExceeded if the constraint returns a limit higher than number of selected utxo.
 *
 * @returns {ComputeSelectionLimit} constraint that returns txSize <= maxTxSize ? utxo[].length : utxo[].length-1
 */
export const computeSelectionLimit =
  (maxTxSize: ProtocolParametersRequiredByInputSelection['maxTxSize'], buildTx: BuildTx): ComputeSelectionLimit =>
  async (selectionSkeleton) => {
    const tx = await buildTx(selectionSkeleton);
    const txSize = getTxSize(tx);
    if (txSize <= maxTxSize) {
      return selectionSkeleton.inputs.size;
    }
    return selectionSkeleton.inputs.size - 1;
  };

export const defaultSelectionConstraints = ({
  protocolParameters: { coinsPerUtxoByte, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant },
  buildTx
}: DefaultSelectionConstraintsProps): SelectionConstraints => {
  if (!coinsPerUtxoByte || !maxTxSize || !maxValueSize || !minFeeCoefficient || !minFeeConstant) {
    throw new InvalidProtocolParametersError(
      'Missing one of: coinsPerUtxoByte, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant'
    );
  }
  return {
    computeMinimumCoinQuantity: computeMinimumCoinQuantity(coinsPerUtxoByte),
    computeMinimumCost: computeMinimumCost({ minFeeCoefficient, minFeeConstant }, buildTx),
    computeSelectionLimit: computeSelectionLimit(maxTxSize, buildTx),
    tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(maxValueSize)
  };
};
