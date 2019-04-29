import { Transaction } from 'cardano-wallet'
import { getBindingsForEnvironment } from '../bindings'
import { TransactionInput, TransactionOutput } from '../../interfaces'
const { TransactionBuilder, TxoPointer, TxOut, Coin, LinearFeeAlgorithm } = getBindingsForEnvironment()

export function buildTransaction (
  inputs: TransactionInput[],
  outputs: TransactionOutput[],
  feeAlgorithm = LinearFeeAlgorithm.default()
): Transaction {
  if (!inputs.length || !outputs.length) {
    throw new Error('Transaction requires both inputs and outputs')
  }

  const transactionBuilder = addInsAndOutsToTransaction(inputs, outputs)

  const balance = transactionBuilder.get_balance(feeAlgorithm)
  if (balance.is_negative()) throw new Error('Outputs outweigh inputs')
  if (balance.is_positive()) throw new Error('Inputs outweigh outputs')

  return transactionBuilder.make_transaction()
}

export function addInsAndOutsToTransaction (inputs: TransactionInput[], outputs: TransactionOutput[]) {
  const transactionBuilder = new TransactionBuilder()

  inputs.forEach(input => {
    const pointer = TxoPointer.from_json(input.pointer)
    const value = Coin.from(0, Number(input.value))
    transactionBuilder.add_input(pointer, value)
  })

  outputs.forEach(output => {
    const txOut = TxOut.from_json(output)
    transactionBuilder.add_output(txOut)
  })

  return transactionBuilder
}
