import { CSL } from '@cardano-sdk/cardano-serialization-lib';

export interface SelectionResult {
  selection: {
    /**
     * A set of inputs, equivalent to a subset of the initial UTxO set.
     *
     * From the point of view of a wallet, this represents the value
     * that has been selected from the wallet in order to cover the total payment value.
     */
    inputs: CSL.TransactionUnspentOutput[];
    /**
     * Set of payments to be made to recipient addresses.
     */
    outputs: CSL.TransactionOutputs;
    /**
     * A set of change values. Does not account for fee.
     *
     * From the point of view of a wallet, this represents the change to be returned to the wallet.
     */
    change: CSL.Value[];
    /**
     * Estimated fee for the transaction.
     * This value is included in 'change', so the actual change returned by the transaction is change-fee.
     */
    fee: bigint;
  };
  /**
   * The remaining UTxO set is a subset of the initial UTxO set.
   *
   * It represents the set of values that remain after the coin selection algorithm
   * has removed values to pay for entries in the requested output set.
   */
  remainingUTxO: CSL.TransactionUnspentOutput[];
}

export interface SelectionSkeleton {
  utxo: CSL.TransactionUnspentOutput[];
  outputs: CSL.TransactionOutputs;
  change: CSL.Value[];
}

/**
 * @returns minimum transaction fee in Lovelace.
 */
export type EstimateTxFee = (selectionSkeleton: SelectionSkeleton) => Promise<bigint>;

/**
 * @returns true if token bundle size exceeds it's maximum size limit.
 */
export type TokenBundleSizeExceedsLimit = (tokenBundle: CSL.MultiAsset) => boolean;

/**
 * @returns minimum lovelace amount in a UTxO
 */
export type ComputeMinimumCoinQuantity = (assetQuantities: CSL.MultiAsset) => bigint;

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

export interface InputSelectionParameters {
  /**
   * The set of inputs available for selection.
   */
  utxo: CSL.TransactionUnspentOutput[];
  /**
   * The set of outputs requested for payment.
   */
  outputs: CSL.TransactionOutputs;
  /**
   * Input selection constraints
   */
  constraints: SelectionConstraints;
}

export interface InputSelector {
  /**
   * Input selection algorithm.
   *
   * @throws InputSelectionError
   */
  select(params: InputSelectionParameters): Promise<SelectionResult>;
}
