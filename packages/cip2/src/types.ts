import { TransactionUnspentOutput, Value, TransactionOutputs } from '@emurgo/cardano-serialization-lib-nodejs';

export interface SelectionResult {
  selection: {
    /**
     * A set of inputs, equivalent to a subset of the initial UTxO set.
     *
     * From the point of view of a wallet, this represents the value
     * that has been selected from the wallet in order to cover the total payment value.
     */
    inputs: TransactionUnspentOutput[];
    /**
     * Set of payments to be made to recipient addresses.
     */
    outputs: TransactionOutputs;
    /**
     * A set of change values. Does not account for fee.
     *
     * From the point of view of a wallet, this represents the change to be returned to the wallet.
     */
    change: Value[];
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
  remainingUTxO: TransactionUnspentOutput[];
}

export type EstimateTxFee = (
  utxo: TransactionUnspentOutput[],
  outputs: TransactionOutputs,
  change: Value[]
) => Promise<bigint>;

export interface InputSelectionParameters {
  /**
   * The set of inputs available for selection.
   */
  utxo: TransactionUnspentOutput[];
  /**
   * The set of outputs requested for payment.
   */
  outputs: TransactionOutputs;
  /**
   * Function to estimate transaction fee for selected inputs.
   */
  estimateTxFee: EstimateTxFee;
  /**
   * A limit on the number of inputs that can be selected.
   */
  maximumInputCount: number;
}

export interface InputSelector {
  /**
   * Input selection algorithm.
   *
   * @throws InputSelectionError
   */
  select(params: InputSelectionParameters): Promise<SelectionResult>;
}
