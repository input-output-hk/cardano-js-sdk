import { Cardano } from '@cardano-sdk/core';

export interface SelectionSkeleton {
  /**
   * A set of inputs, equivalent to a subset of the initial UTxO set.
   *
   * From the point of view of a wallet, this represents the value
   * that has been selected from the wallet in order to cover the total payment value.
   */
  inputs: Set<Cardano.Utxo>;
  /**
   * Set of payments to be made to recipient addresses.
   */
  outputs: Set<Cardano.TxOut>;
  /**
   * A set of change values. Does not account for fee.
   *
   * From the point of view of a wallet, this represents the change to be returned to the wallet.
   */
  change: Set<Cardano.Value>;
  /**
   * Estimated fee for the transaction.
   * This value is included in 'change', so the actual change returned by the transaction is change-fee.
   */
  fee: Cardano.Lovelace;
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
  remainingUTxO: Set<Cardano.Utxo>;
}

/**
 * @returns minimum transaction fee in Lovelace.
 */
export type EstimateTxFee = (selectionSkeleton: SelectionSkeleton) => Promise<Cardano.Lovelace>;

/**
 * @returns true if token bundle size exceeds it's maximum size limit.
 */
export type TokenBundleSizeExceedsLimit = (tokenBundle?: Cardano.TokenMap) => boolean;

/**
 * @returns minimum lovelace amount in a UTxO
 */
export type ComputeMinimumCoinQuantity = (output: Cardano.TxOut) => Cardano.Lovelace;

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
 * Implicit input or spent value
 */
export interface ImplicitValue {
  /**
   * Implicit coin quantities used in the transaction
   */
  coin?: Cardano.util.ImplicitCoin;
  /**
   * Positive quantity = mint (implicit input)
   * Negative quantity = burn (implicit spend)
   */
  mint?: Cardano.TokenMap;
}

export interface InputSelectionParameters {
  /**
   * The set of inputs available for selection.
   */
  utxo: Set<Cardano.Utxo>;
  /**
   * The set of outputs requested for payment.
   */
  outputs: Set<Cardano.TxOut>;
  /**
   * Input selection constraints
   */
  constraints: SelectionConstraints;
  /**
   * Implicit input or spent value
   */
  implicitValue?: ImplicitValue;
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
  Cardano.ProtocolParameters,
  'coinsPerUtxoByte' | 'maxTxSize' | 'maxValueSize' | 'minFeeCoefficient' | 'minFeeConstant'
>;

export type ProtocolParametersRequiredByInputSelection = Required<{
  [k in keyof ProtocolParametersForInputSelection]: ProtocolParametersForInputSelection[k];
}>;
