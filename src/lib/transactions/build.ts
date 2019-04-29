import { getBindingsForEnvironment } from '../bindings'
import { TransactionInput, TransactionOutput } from '../../interfaces'
const { TransactionBuilder, TxoPointer, TxOut, Coin, LinearFeeAlgorithm } = getBindingsForEnvironment()

export function buildTransaction(
  inputs: TransactionInput[],
  outputs: TransactionOutput[],
  feeAlgorithm = LinearFeeAlgorithm.default()
) {
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

  if (balance.is_negative()) throw new Error('Too few inputs')
  if (!balance.is_zero()) throw new Error('Balance lost to dust')

  return transactionBuilder.make_transaction()
}