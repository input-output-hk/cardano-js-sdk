import { Transaction } from 'cardano-wallet'
import { getBindingsForEnvironment } from '../bindings'
import { TransactionInput, TransactionOutput } from '../../interfaces'
const { TransactionBuilder, TxoPointer, TxOut, Coin, LinearFeeAlgorithm } = getBindingsForEnvironment()

export function buildTransaction (
  inputs: TransactionInput[],
  outputs: TransactionOutput[],
  feeAlgorithm = LinearFeeAlgorithm.default()
): Transaction {
  const transactionBuilder = new TransactionBuilder()

  if (!inputs.length || !outputs.length) {
    throw new Error('Transaction requires both inputs and outputs')
  }

  inputs.forEach(input => {
    const pointer = TxoPointer.from_json(input.pointer)
    const value = Coin.from(input.value, 0)
    transactionBuilder.add_input(pointer, value)
  })

  outputs.forEach(output => {
    const txOut = TxOut.from_json(output)
    transactionBuilder.add_output(txOut)
  })

  const balance = transactionBuilder.get_balance(feeAlgorithm)
  console.log(balance.value().to_str())

  if (balance.is_negative()) throw new Error('Too many inputs')
  if (balance.is_positive()) throw new Error('Too few inputs')

  return transactionBuilder.make_transaction()
}
