import { CustomError } from 'ts-custom-error';

export enum InputSelectionFailure {
  /**
   * Total value of the entries within the initial UTxO set (the amount of money available)
   * is less than the total value of all entries in the requested output set (the amount of money required).
   */
  UtxoBalanceInsufficient = 'UTxO Balance Insufficient',
  /**
   * The number of entries in the initial UTxO set is smaller than the number of entries in the requested output set,
   * for algorithms that impose the restriction that a single UTxO entry can only be used to pay for at most one output.
   */
  UtxoNotFragmentedEnough = 'UTxO Not Fragmented Enough',
  /**
   * The algorithm depletes all entries from the initial UTxO set
   * before it is able to pay for all outputs in the requested output set.
   * This can happen even if the total value of entries within the initial UTxO set
   * is greater than the total value of all entries in the requested output set,
   * due to various restrictions that coin selection algorithms impose on themselves when selecting UTxO entries.
   */
  UtxoFullyDepleted = 'UTxO Fully Depleted',
  /**
   * Another input must be selected by the algorithm in order to continue making progress,
   * but doing so will increase the size of the resulting selection beyond an acceptable limit,
   * specified by the maximum input count parameter.
   */
  MaximumInputCountExceeded = 'Maximum Input Count Exceeded'
}

export class InputSelectionError extends CustomError {
  public constructor(public failure: InputSelectionFailure) {
    super(failure);
  }
}
