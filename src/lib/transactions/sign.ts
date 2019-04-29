import { Transaction, PrivateKey } from 'cardano-wallet'
import { getBindingsForEnvironment } from '../bindings'
const { TransactionFinalized, BlockchainSettings } = getBindingsForEnvironment()

export function signTransaction (
  transaction: Transaction,
  privateKey: PrivateKey,
  settings = BlockchainSettings.mainnet()
): string {
  let transactionFinalizer = new TransactionFinalized(transaction)

  // TODO: Sign for the number of inputs
  console.log(transaction)
  transactionFinalizer.sign(settings, privateKey)

  const signedTransaction = transactionFinalizer.finalize()
  return signedTransaction.to_hex()
}
