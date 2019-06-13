import { AddressType } from '../Wallet'
import Transaction, { TransactionInput } from '../Transaction'
import { ChainSettings } from '../Cardano'

export interface KeyManager {
  signTransaction: (transaction: ReturnType<typeof Transaction>, inputs: TransactionInput[], chainSettings?: ChainSettings, transactionsAsProofForSpending?: { [transactionId: string]: string }) => Promise<string>
  signMessage: (addressType: AddressType, signingIndex: number, message: string) => Promise<{ publicKey: string, signature: string }>
  publicParentKey: () => Promise<string>
}
