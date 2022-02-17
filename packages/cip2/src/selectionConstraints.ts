import { CSL, InvalidProtocolParametersError, coreToCsl, cslUtil } from '@cardano-sdk/core';
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

export type BuildTx = (selection: SelectionSkeleton) => Promise<CSL.Transaction>;

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
    return (
      BigInt(
        CSL.min_fee(
          tx,
          CSL.LinearFee.new(
            CSL.BigNum.from_str(minFeeCoefficient.toString()),
            CSL.BigNum.from_str(minFeeConstant.toString())
          )
        ).to_str()
        // TODO: for some reason this works unreliably for transactions with metadata.
        // Figure out why and remove the hardcoded +lovelace
      ) + 10_000n
    );
  };

export const computeMinimumCoinQuantity =
  (coinsPerUtxoWord: ProtocolParametersRequiredByInputSelection['coinsPerUtxoWord']): ComputeMinimumCoinQuantity =>
  (multiasset) => {
    const minUTxOValue = CSL.BigNum.from_str((coinsPerUtxoWord * 29).toString());
    const value = CSL.Value.new(CSL.BigNum.from_str('0'));
    if (multiasset) {
      value.set_multiasset(coreToCsl.tokenMap(multiasset));
    }
    return BigInt(CSL.min_ada_required(value, minUTxOValue).to_str());
  };

export const tokenBundleSizeExceedsLimit =
  (maxValueSize: ProtocolParametersRequiredByInputSelection['maxValueSize']): TokenBundleSizeExceedsLimit =>
  (tokenBundle) => {
    if (!tokenBundle) {
      return false;
    }
    const value = CSL.Value.new(cslUtil.maxBigNum);
    value.set_multiasset(coreToCsl.tokenMap(tokenBundle));
    return value.to_bytes().length > maxValueSize;
  };

const getTxSize = (tx: CSL.Transaction) => tx.to_bytes().length;

/**
 * This constraint implementation is not intended to used by selection algorithms
 * that adjust selection based on selection limit. RRRI implementation uses this after selecting all the inputs
 * and throws MaximumInputCountExceeded if the constraint returns a limit higher than number of selected utxo.
 *
 * @returns {ComputeSelectionLimit} constraint that returns txSize <= maxTxSize ? utxo[].length : utxo[].length+1
 */
export const computeSelectionLimit =
  (maxTxSize: ProtocolParametersRequiredByInputSelection['maxTxSize'], buildTx: BuildTx): ComputeSelectionLimit =>
  async (selectionSkeleton) => {
    const tx = await buildTx(selectionSkeleton);
    const txSize = getTxSize(tx);
    if (txSize <= maxTxSize) {
      return selectionSkeleton.inputs.size;
    }
    return selectionSkeleton.inputs.size + 1;
  };

export const defaultSelectionConstraints = ({
  protocolParameters: { coinsPerUtxoWord, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant },
  buildTx
}: DefaultSelectionConstraintsProps): SelectionConstraints => {
  if (!coinsPerUtxoWord || !maxTxSize || !maxValueSize || !minFeeCoefficient || !minFeeConstant) {
    throw new InvalidProtocolParametersError(
      'Missing one of: coinsPerUtxoWord, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant'
    );
  }
  return {
    computeMinimumCoinQuantity: computeMinimumCoinQuantity(coinsPerUtxoWord),
    computeMinimumCost: computeMinimumCost({ minFeeCoefficient, minFeeConstant }, buildTx),
    computeSelectionLimit: computeSelectionLimit(maxTxSize, buildTx),
    tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(maxValueSize)
  };
};
