import { Cardano, InvalidProtocolParametersError, Serialization } from '@cardano-sdk/core';
import {
  ComputeMinimumCoinQuantity,
  ComputeSelectionLimit,
  EstimateTxFee,
  ProtocolParametersForInputSelection,
  ProtocolParametersRequiredByInputSelection,
  SelectionConstraints,
  SelectionSkeleton,
  TokenBundleSizeExceedsLimit
} from '@cardano-sdk/input-selection';
import { MinFeeCoefficient, MinFeeConstant, minAdaRequired, minFee } from '../fees';

export const MAX_U64 = 18_446_744_073_709_551_615n;

export type BuildTx = (selection: SelectionSkeleton) => Promise<Cardano.Tx>;

export interface DefaultSelectionConstraintsProps {
  protocolParameters: ProtocolParametersForInputSelection;
  buildTx: BuildTx;
}

export const computeMinimumCost =
  (
    {
      minFeeCoefficient,
      minFeeConstant,
      prices
    }: Pick<ProtocolParametersRequiredByInputSelection, 'minFeeCoefficient' | 'minFeeConstant' | 'prices'>,
    buildTx: BuildTx
  ): EstimateTxFee =>
  async (selection) => {
    const tx = await buildTx(selection);

    return minFee(tx, prices, MinFeeConstant(minFeeConstant), MinFeeCoefficient(minFeeCoefficient));
  };

export const computeMinimumCoinQuantity =
  (coinsPerUtxoByte: ProtocolParametersRequiredByInputSelection['coinsPerUtxoByte']): ComputeMinimumCoinQuantity =>
  (output) =>
    minAdaRequired(output, BigInt(coinsPerUtxoByte));

export const tokenBundleSizeExceedsLimit =
  (maxValueSize: ProtocolParametersRequiredByInputSelection['maxValueSize']): TokenBundleSizeExceedsLimit =>
  (tokenBundle) => {
    if (!tokenBundle) {
      return false;
    }

    const value = new Serialization.Value(MAX_U64);
    value.setMultiasset(tokenBundle);

    return value.toCbor().length / 2 > maxValueSize;
  };

const getTxSize = (tx: Serialization.Transaction) => Buffer.from(tx.toCbor(), 'hex').length;

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
    const txSize = getTxSize(Serialization.Transaction.fromCore(tx));
    if (txSize <= maxTxSize) {
      return selectionSkeleton.inputs.size;
    }
    return selectionSkeleton.inputs.size - 1;
  };

export const defaultSelectionConstraints = ({
  protocolParameters: { coinsPerUtxoByte, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant, prices },
  buildTx
}: DefaultSelectionConstraintsProps): SelectionConstraints => {
  if (!coinsPerUtxoByte || !maxTxSize || !maxValueSize || !minFeeCoefficient || !minFeeConstant || !prices) {
    throw new InvalidProtocolParametersError(
      'Missing one of: coinsPerUtxoByte, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant, prices'
    );
  }
  return {
    computeMinimumCoinQuantity: computeMinimumCoinQuantity(coinsPerUtxoByte),
    computeMinimumCost: computeMinimumCost({ minFeeCoefficient, minFeeConstant, prices }, buildTx),
    computeSelectionLimit: computeSelectionLimit(maxTxSize, buildTx),
    tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(maxValueSize)
  };
};
