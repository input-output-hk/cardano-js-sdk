import { Provider, CardanoProvider, WalletProvider, ProviderType } from '../Provider'
import { Cardano, FeeAlgorithm, TransactionSelection } from '../Cardano'
import { Address } from './Address'
import { ClientWallet, RemoteWallet } from '../lib'
import { RemotePayment } from '../Remote'
import { TransactionOutput, TransactionInput } from '../Transaction'

export interface WalletInstance {
  getNextReceivingAddress: () => Promise<Address>
  getNextChangeAddress: () => Promise<Address>
  balance: () => Promise<number>
  transactions: () => Promise<{ id: string, inputs: TransactionInput[], outputs: TransactionOutput[] }[]>
  selectInputsForTransaction: (paymentOutputs: TransactionOutput[], feeAlgorithm?: FeeAlgorithm) => Promise<TransactionSelection>
  createAndSignTransaction: (payments: RemotePayment[], passphrase: string) => Promise<{ id: string, inputs: TransactionInput[], outputs: TransactionOutput[] }>
}

type WalletConstructor = (walletInstanceArgs: { publicParentKey?: string, walletId?: string }) => WalletInstance

export function Wallet (cardano: Cardano, provider: Provider): WalletConstructor {
  if (provider.type === ProviderType.client) {
    return ({ publicParentKey }) => {
      if (!publicParentKey) {
        throw new Error('The client wallet implementation requires access to the parent public key from a local key chain.')
      }

      return ClientWallet(cardano, <CardanoProvider>provider, publicParentKey)
    }
  } else {
    return ({ walletId }) => {
      if (!walletId) {
        throw new Error('Remote wallet providers require reference to the walletId.')
      }

      return RemoteWallet(<WalletProvider>provider, walletId)
    }
  }
}
