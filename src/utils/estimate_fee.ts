import { getBindingsForEnvironment } from '../lib/bindings'
import { TransactionInput, TransactionOutput, buildTransaction } from '../Transaction'
import { convertCoinToLovelace } from './coin_to_lovelace';
const { LinearFeeAlgorithm } = getBindingsForEnvironment()

export function estimateTransactionFee(inputs: TransactionInput[], outputs: TransactionOutput[], feeAlgorithm = LinearFeeAlgorithm.default()): string {
  const feeEstimate = buildTransaction(inputs, outputs).estimate_fee(feeAlgorithm)
  return convertCoinToLovelace(feeEstimate)
}