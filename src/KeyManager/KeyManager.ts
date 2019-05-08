import { BlockchainSettings as CardanoBlockchainSettings, Bip44AccountPublic } from 'cardano-wallet'
import { AddressType } from '../Wallet'
import Transaction, { TransactionInput } from '../Transaction'

export interface KeyManager {
  signTransaction: (transaction: ReturnType<typeof Transaction>, inputs: TransactionInput[], chainSettings?: CardanoBlockchainSettings) => string
  signMessage: (addressType: AddressType, signingIndex: number, message: string) => { publicKey: string, signature: string }
  publicAccount: () => Bip44AccountPublic
}
