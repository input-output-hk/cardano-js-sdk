import { Transaction as CardanoTransaction, TransactionBuilder as CardanoTransactionBuilder, LinearFeeAlgorithm as CardanoLinearFeeAlgorithm } from 'cardano-wallet'
import { getBindingsForEnvironment } from '../lib/bindings'
import { InsufficientTransactionInput } from './errors'
import { TransactionInput, TransactionInputCodec } from './TransactionInput'
import { TransactionOutput, TransactionOutputCodec } from './TransactionOutput'
import { validateCodec } from '../lib/validator'
const { TransactionBuilder, TxoPointer, TxOut, Coin, LinearFeeAlgorithm } = getBindingsForEnvironment()

export function Transaction(inputs: TransactionInput[], outputs: TransactionOutput[]): {
  estimateNetworkFee: (feeAlgorithm?: CardanoLinearFeeAlgorithm) => string
  fee: () => string
  validateAndMake: () => CardanoTransaction
  builder: CardanoTransactionBuilder
} {
  validateCodec<typeof TransactionInputCodec>(TransactionInputCodec, inputs)
  validateCodec<typeof TransactionOutputCodec>(TransactionOutputCodec, outputs)

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

  return {
    estimateNetworkFee: (feeAlgorithm = LinearFeeAlgorithm.default()): string => {
      const fee = transactionBuilder.estimate_fee(feeAlgorithm)
      return fee.lovelace().toString()
    },
    fee: () => {
      const realisedFee = transactionBuilder.get_balance_without_fees().value()
      const ada = realisedFee.ada()
      const lovelace = realisedFee.lovelace()
      return String((ada * 1000000) + lovelace)
    },
    validateAndMake: (feeAlgorithm = LinearFeeAlgorithm.default()) => {
      const balance = transactionBuilder.get_balance(feeAlgorithm)
      if (balance.is_negative()) throw new InsufficientTransactionInput()

      return transactionBuilder.make_transaction()
    },
    builder: transactionBuilder
  }
}
