import { CardanoSerializationLib, CSL, ProtocolParametersRequiredByWallet } from '@cardano-sdk/core';
import { ComputeSelectionLimit, SelectionConstraints, TokenBundleSizeExceedsLimit } from '.';
import { ComputeMinimumCoinQuantity, EstimateTxFee, SelectionSkeleton } from './types';

export type BuildTx = (selection: SelectionSkeleton) => Promise<CSL.Transaction>;
export interface DefaultSelectionConstraintsProps {
  csl: CardanoSerializationLib;
  protocolParams: ProtocolParametersRequiredByWallet;
  buildTx: BuildTx;
}

export const computeMinimumCost =
  (
    csl: CardanoSerializationLib,
    { minFeeCoefficient, minFeeConstant }: ProtocolParametersRequiredByWallet,
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
  (
    csl: CardanoSerializationLib,
    { coinsPerUtxoWord }: ProtocolParametersRequiredByWallet
  ): ComputeMinimumCoinQuantity =>
  (multiasset) => {
    const minUTxOValue = CSL.BigNum.from_str((coinsPerUtxoWord * 29).toString());
    const value = csl.Value.new(csl.BigNum.from_str('0'));
    if (multiasset) {
      value.set_multiasset(multiasset);
    }
    return BigInt(csl.min_ada_required(value, minUTxOValue).to_str());
  };

export const tokenBundleSizeExceedsLimit =
  (csl: CardanoSerializationLib, { maxValueSize }: ProtocolParametersRequiredByWallet): TokenBundleSizeExceedsLimit =>
  (tokenBundle) => {
    if (!tokenBundle) {
      return false;
    }
    // Review: assuming coin serializes to the same size regardless of quantity
    const value = csl.Value.new(csl.BigNum.from_str('0'));
    value.set_multiasset(tokenBundle);
    return value.to_bytes().length > maxValueSize;
  };

// TODO: move this to core package and test it by comparing
// the result to result of serializing the transaction via cardano-cli
const getTxSize = (tx: CSL.Transaction) => tx.to_bytes().length;

/**
 * This constraint implementation is not intended to used by selection algorithms
 * that adjust selection based on selection limit. RRRI implementation uses this after selecting all the inputs
 * and throws MaximumInputCountExceeded if the constraint returns a limit higher than number of selected utxo.
 *
 * @returns {ComputeSelectionLimit} constraint that returns txSize <= maxTxSize ? utxo[].length : utxo[].length+1
 */
export const computeSelectionLimit =
  ({ maxTxSize }: ProtocolParametersRequiredByWallet, buildTx: BuildTx): ComputeSelectionLimit =>
  async (selectionSkeleton) => {
    const tx = await buildTx(selectionSkeleton);
    const txSize = getTxSize(tx);
    if (txSize <= maxTxSize) {
      return selectionSkeleton.utxo.length;
    }
    return selectionSkeleton.utxo.length + 1;
  };

export const defaultSelectionConstraints = ({
  csl,
  protocolParams,
  buildTx
}: DefaultSelectionConstraintsProps): SelectionConstraints => ({
  computeMinimumCost: computeMinimumCost(csl, protocolParams, buildTx),
  computeMinimumCoinQuantity: computeMinimumCoinQuantity(csl, protocolParams),
  computeSelectionLimit: computeSelectionLimit(protocolParams, buildTx),
  tokenBundleSizeExceedsLimit: tokenBundleSizeExceedsLimit(csl, protocolParams)
});
