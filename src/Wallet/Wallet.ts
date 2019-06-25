import { Provider, CardanoProvider, WalletProvider, ProviderType } from '../Provider'
import { Cardano, FeeAlgorithm, TransactionSelection } from '../Cardano'
import { Address } from './Address'
import { ClientWallet, RemoteWallet } from '../lib'
import { RemotePayment } from './RemotePayment'
import { TransactionOutput } from '../Transaction'

export interface WalletInstance {
  getNextReceivingAddress: () => Promise<Address>
  getNextChangeAddress: () => Promise<Address>
  balance: () => Promise<number>
  transactions: () => Promise<any>
  selectInputsForTransaction: (paymentOutputs: TransactionOutput[], feeAlgorithm: FeeAlgorithm) => Promise<TransactionSelection>
  createAndSignTransaction: (payments: RemotePayment[], passphrase: string) => Promise<any>
}

type WalletConstructor = (walletInstanceArgs: { parentPublicKey: string, walletId: number }) => WalletInstance

export function Wallet (cardano: Cardano, provider: Provider): WalletConstructor {
  if (provider.type === ProviderType.client) {
    return ({ parentPublicKey: account }) => {
      if (!account) {
        throw new Error('The client wallet implementation requires access to the parent public key')
      }

      return ClientWallet(cardano, <CardanoProvider>provider, account)
    }
  } else {
    return ({ walletId }) => {
      if (!walletId) {
        throw new Error('Remote wallet providers require reference to the walletId')
      }

      return RemoteWallet(<WalletProvider>provider, walletId)
    }
  }
}
