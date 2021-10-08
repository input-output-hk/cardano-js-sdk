import { Lovelace, ProtocolParametersAlonzo } from '@cardano-ogmios/schema';
import { CSL } from '@cardano-sdk/core';

export interface SelectionSkeleton {
  /**
   * A set of inputs, equivalent to a subset of the initial UTxO set.
   *
   * From the point of view of a wallet, this represents the value
   * that has been selected from the wallet in order to cover the total payment value.
   */
  inputs: Set<CSL.TransactionUnspentOutput>;
  /**
   * Set of payments to be made to recipient addresses.
   */
  outputs: Set<CSL.TransactionOutput>;
  /**
   * A set of change values. Does not account for fee.
   *
   * From the point of view of a wallet, this represents the change to be returned to the wallet.
   */
  change: Set<CSL.Value>;
  /**
   * Estimated fee for the transaction.
   * This value is included in 'change', so the actual change returned by the transaction is change-fee.
   */
  fee: CSL.BigNum;
}

export type Selection = SelectionSkeleton;

export interface SelectionResult {
  selection: Selection;
  /**
   * The remaining UTxO set is a subset of the initial UTxO set.
   *
   * It represents the set of values that remain after the coin selection algorithm
   * has removed values to pay for entries in the requested output set.
   */
  remainingUTxO: Set<CSL.TransactionUnspentOutput>;
}

/**
 * @returns minimum transaction fee in Lovelace.
 */
export type EstimateTxFee = (selectionSkeleton: SelectionSkeleton) => Promise<bigint>;

/**
 * @returns true if token bundle size exceeds it's maximum size limit.
 */
export type TokenBundleSizeExceedsLimit = (tokenBundle?: CSL.MultiAsset) => boolean;

/**
 * @returns minimum lovelace amount in a UTxO
 */
export type ComputeMinimumCoinQuantity = (assetQuantities?: CSL.MultiAsset) => bigint;

/**
 * @returns an upper bound for the number of ordinary inputs to
 * select, given a current set of outputs.
 */
export type ComputeSelectionLimit = (selectionSkeleton: SelectionSkeleton) => Promise<number>;

export interface SelectionConstraints {
  computeMinimumCost: EstimateTxFee;
  tokenBundleSizeExceedsLimit: TokenBundleSizeExceedsLimit;
  computeMinimumCoinQuantity: ComputeMinimumCoinQuantity;
  computeSelectionLimit: ComputeSelectionLimit;
}

/**
 * Implicit coin quantities used in the transaction
 */
export interface ImplicitCoin {
  /**
   * Delegation withdrawals + reclaims
   */
  input?: Lovelace;
  /**
   * Delegation registration deposit
   */
  deposit?: Lovelace;
}

export interface InputSelectionParameters {
  /**
   * The set of inputs available for selection.
   */
  utxo: Set<CSL.TransactionUnspentOutput>;
  /**
   * The set of outputs requested for payment.
   */
  outputs: Set<CSL.TransactionOutput>;
  /**
   * Input selection constraints
   */
  constraints: SelectionConstraints;
  /**
   * Implicit coin quantities used in the transaction
   */
  implicitCoin?: ImplicitCoin;
}

export interface InputSelector {
  /**
   * Input selection algorithm.
   *
   * @throws InputSelectionError
   */
  select(params: InputSelectionParameters): Promise<SelectionResult>;
}

export type ProtocolParametersForInputSelection = Pick<
  ProtocolParametersAlonzo,
  'coinsPerUtxoWord' | 'maxTxSize' | 'maxValueSize' | 'minFeeCoefficient' | 'minFeeConstant'
>;

export type ProtocolParametersRequiredByInputSelection = {
  [k in keyof ProtocolParametersForInputSelection]: NonNullable<ProtocolParametersForInputSelection[k]>;
};
