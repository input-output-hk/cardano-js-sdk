import { CardanoSerializationLib, CSL, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { ComputeSelectionLimit, SelectionConstraints, TokenBundleSizeExceedsLimit } from '.';
import { ComputeMinimumCoinQuantity, EstimateTxFee, SelectionSkeleton } from './types';
import { maxBigNum } from './util';

export type BuildTx = (selection: SelectionSkeleton) => Promise<CSL.Transaction>;

// Review: we might want to use this for ProtocolParametersRequiredByWallet instead
type NonNullableFields<T> = {
  [K in keyof T]: NonNullable<T[K]>;
};
export type ProtocolParametersRequiredBySelectionConstraints = NonNullableFields<
  Pick<
    ProtocolParametersRequiredByWallet,
    'coinsPerUtxoWord' | 'maxTxSize' | 'maxValueSize' | 'minFeeCoefficient' | 'minFeeConstant'
  >
>;

export interface DefaultSelectionConstraintsProps {
  csl: CardanoSerializationLib;
  protocolParameters: ProtocolParametersRequiredBySelectionConstraints;
  buildTx: BuildTx;
}

export const computeMinimumCost =
  (
    csl: CardanoSerializationLib,
    { minFeeCoefficient, minFeeConstant }: { minFeeCoefficient: number; minFeeConstant: number },
    buildTx: BuildTx
  ): EstimateTxFee =>
  async (selection) => {
    const tx = await buildTx(selection);
    return BigInt(
      csl
        .min_fee(
          tx,
          csl.LinearFee.new(
            csl.BigNum.from_str(minFeeCoefficient.toString()),
            csl.BigNum.from_str(minFeeConstant.toString())
          )
        )
        .to_str()
    );
  };

export const computeMinimumCoinQuantity =
  (csl: CardanoSerializationLib, coinsPerUtxoWord: number): ComputeMinimumCoinQuantity =>
  (multiasset) => {
    const minUTxOValue = csl.BigNum.from_str((coinsPerUtxoWord * 29).toString());
    const value = csl.Value.new(csl.BigNum.from_str('0'));
    if (multiasset) {
      value.set_multiasset(multiasset);
    }
    return BigInt(csl.min_ada_required(value, minUTxOValue).to_str());
  };

export const tokenBundleSizeExceedsLimit =
  (csl: CardanoSerializationLib, maxValueSize: number): TokenBundleSizeExceedsLimit =>
  (tokenBundle) => {
    if (!tokenBundle) {
      return false;
    }
    const value = csl.Value.new(maxBigNum(csl));
    value.set_multiasset(tokenBundle);
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
  (maxTxSize: number, buildTx: BuildTx): ComputeSelectionLimit =>
  async (selectionSkeleton) => {
    const tx = await buildTx(selectionSkeleton);
    const txSize = getTxSize(tx);
    if (txSize <= maxTxSize) {
      return selectionSkeleton.inputs.length;
    }
    return selectionSkeleton.inputs.length + 1;
  };

export const defaultSelectionConstraints = ({
  csl,
  protocolParameters: { coinsPerUtxoWord, maxTxSize, maxValueSize, minFeeCoefficient, minFeeConstant },
  buildTx
}: DefaultSelectionConstraintsProps): SelectionConstraints => ({
  computeMinimumCost: computeMinimumCost(csl, { minFeeCoefficient, minFeeConstant }, buildTx),
  computeMinimumCoinQuantity: computeMinimumCoinQuantity(csl, coinsPerUtxoWord),
  computeSelectionLimit: computeSelectionLimit(maxTxSize, buildTx),
  tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(csl, maxValueSize)
});
