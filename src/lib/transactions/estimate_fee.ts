import { getBindingsForEnvironment } from '../bindings'
import { addInsAndOutsToTransaction } from './build'
import { TransactionInput, TransactionOutput } from '../../interfaces'
const { LinearFeeAlgorithm } = getBindingsForEnvironment()

export function estimateTransactionFee (
  inputs: TransactionInput[],
  outputs: TransactionOutput[],
  feeAlgorithm = LinearFeeAlgorithm.default()
): string {
  const transactionBuilder = addInsAndOutsToTransaction(inputs, outputs)
  const fee = transactionBuilder.estimate_fee(feeAlgorithm)
  return fee.lovelace().toString()
}
