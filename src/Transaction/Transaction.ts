import { getBindingsForEnvironment } from '../lib/bindings'
import { InsufficientTransactionInput } from './errors'
import { TransactionInput, TransactionInputCodec } from './TransactionInput'
import { TransactionOutput, TransactionOutputCodec } from './TransactionOutput'
import { validateCodec } from '../lib/validator'
import { convertCoinToLovelace } from '../Utils'
const { TransactionBuilder, TxoPointer, TxOut, Coin, LinearFeeAlgorithm, TransactionFinalized } = getBindingsForEnvironment()

export function Transaction (inputs: TransactionInput[], outputs: TransactionOutput[], feeAlgorithm = LinearFeeAlgorithm.default()) {
  validateCodec<typeof TransactionInputCodec>(TransactionInputCodec, inputs)
  validateCodec<typeof TransactionOutputCodec>(TransactionOutputCodec, outputs)

  const transactionBuilder = buildTransaction(inputs, outputs)

  const balance = transactionBuilder.get_balance(feeAlgorithm)
  if (balance.is_negative()) throw new InsufficientTransactionInput()

  /*
    The get_balance_without_fees from the WASM bindings returns:

    Σ(transactionInputValues) - Σ(transactionOutputValues)

    This represents the fee paid on a transaction, as the positive balance
    between inputs and the associated outputs is equal to the fee paid
  */
  const feeAsCoinType = transactionBuilder.get_balance_without_fees().value()
  const fee = convertCoinToLovelace(feeAsCoinType)

  const cardanoTransaction = transactionBuilder.make_transaction()

  return {
    toHex: () => cardanoTransaction.to_hex(),
    toJson: () => cardanoTransaction.to_json(),
    id: () => cardanoTransaction.id(),
    finalize: () => new TransactionFinalized(cardanoTransaction),
    fee: () => fee
  }
}

export function buildTransaction (inputs: TransactionInput[], outputs: TransactionOutput[]) {
  const transactionBuilder = new TransactionBuilder()

  inputs.forEach(input => {
    const pointer = TxoPointer.from_json(input.pointer)
    const value = Coin.from(0, Number(input.value.value))
    transactionBuilder.add_input(pointer, value)
  })

  outputs.forEach(output => {
    const txOut = TxOut.from_json(output)
    transactionBuilder.add_output(txOut)
  })

  return transactionBuilder
}
