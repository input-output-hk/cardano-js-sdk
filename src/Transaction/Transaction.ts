import { Transaction as CardanoTransaction, TransactionBuilder as CardanoTransactionBuilder, LinearFeeAlgorithm as CardanoLinearFeeAlgorithm } from 'cardano-wallet'
import { getBindingsForEnvironment } from '../lib/bindings'
import { TransactionInput } from './TransactionInput'
import { TransactionOutput } from './TransactionOutput'
const { TransactionBuilder, TxoPointer, TxOut, Coin, LinearFeeAlgorithm } = getBindingsForEnvironment()

export interface ClientTransaction {
  estimateFee: (feeAlgorithm?: CardanoLinearFeeAlgorithm) => string
  finalize: () => CardanoTransaction,
  builder: CardanoTransactionBuilder
}

export function Transaction (inputs: TransactionInput[], outputs: TransactionOutput[]): ClientTransaction {
  const transactionBuilder = new TransactionBuilder()

  if (!inputs.length || !outputs.length) {
    throw new Error('Transaction requires both inputs and outputs')
  }

  inputs.forEach(input => {
    const pointer = TxoPointer.from_json(input.pointer)
    const value = Coin.from(0, Number(input.value))
    transactionBuilder.add_input(pointer, value)
  })

  outputs.forEach(output => {
    const txOut = TxOut.from_json(output)
    transactionBuilder.add_output(txOut)
  })

  return {
    estimateFee: estimateTransactionFee.bind(null, transactionBuilder),
    finalize: finalize.bind(null, transactionBuilder),
    builder: transactionBuilder
  }
}

export function finalize (
  transactionBuilder: CardanoTransactionBuilder,
  feeAlgorithm = LinearFeeAlgorithm.default()
): CardanoTransaction {
  const balance = transactionBuilder.get_balance(feeAlgorithm)
  if (balance.is_negative()) throw new Error('Outputs outweigh inputs')
  if (balance.is_positive()) throw new Error('Inputs outweigh outputs')

  return transactionBuilder.make_transaction()
}

export function estimateTransactionFee (
  transactionBuilder: CardanoTransactionBuilder,
  feeAlgorithm = LinearFeeAlgorithm.default()
): string {
  const fee = transactionBuilder.estimate_fee(feeAlgorithm)
  return fee.lovelace().toString()
}
