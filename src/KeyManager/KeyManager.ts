import { Transaction as CardanoTransaction, BlockchainSettings as CardanoBlockchainSettings, Bip44AccountPublic } from 'cardano-wallet'
import { AddressType } from '../Wallet'
import { TransactionInput } from '../Transaction'

export interface KeyManager {
  signTransaction: (transaction: CardanoTransaction, inputs: TransactionInput[], chainSettings?: CardanoBlockchainSettings) => string
  signMessage: (addressType: AddressType, signingIndex: number, message: string) => { publicKey: string, signature: string }
  publicAccount: () => Bip44AccountPublic
}
