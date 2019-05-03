import { Transaction as CardanoTransaction, BlockchainSettings as CardanoBlockchainSettings, Bip44AccountPrivate } from 'cardano-wallet'
import { AddressType } from '../Wallet'
import { TransactionInput } from '../Transaction'

export interface KeyManager {
  signTransaction: (key: Bip44AccountPrivate, transaction: CardanoTransaction, inputs: TransactionInput[], chainSettings?: CardanoBlockchainSettings) => string
  signMessage: (key: Bip44AccountPrivate, addressType: AddressType, signingIndex: number, message: string) => string
}
