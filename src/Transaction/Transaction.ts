import { TransactionInput, TransactionInputCodec } from './TransactionInput'
import { TransactionOutput, TransactionOutputCodec } from './TransactionOutput'
import { validateCodec } from '../lib/validator'
import { RustCardano, FeeAlgorithm } from '../Cardano'

export function Transaction (inputs: TransactionInput[], outputs: TransactionOutput[], cardano = RustCardano, feeAlgorithm = FeeAlgorithm.default) {
  validateCodec<typeof TransactionInputCodec>(TransactionInputCodec, inputs)
  validateCodec<typeof TransactionOutputCodec>(TransactionOutputCodec, outputs)
  return cardano.buildTransaction(inputs, outputs, feeAlgorithm)
}
