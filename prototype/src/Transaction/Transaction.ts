import { TransactionInput, TransactionInputCodec } from './TransactionInput'
import { TransactionOutput, TransactionOutputCodec } from './TransactionOutput'
import { validateCodec } from '../lib/validator'
import { FeeAlgorithm, Cardano } from '../Cardano'

export function Transaction (cardano: Cardano, inputs: TransactionInput[], outputs: TransactionOutput[], feeAlgorithm = FeeAlgorithm.default) {
  validateCodec<typeof TransactionInputCodec>(TransactionInputCodec, inputs)
  validateCodec<typeof TransactionOutputCodec>(TransactionOutputCodec, outputs)
  return cardano.buildTransaction(inputs, outputs, feeAlgorithm)
}
