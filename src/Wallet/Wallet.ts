import { Provider, CardanoProvider, WalletProvider, ProviderType } from '../Provider'
import { Cardano, FeeAlgorithm, TransactionSelection } from '../Cardano'
import { Address } from './Address'
import { ClientWallet, RemoteWallet } from '../lib'
import { RemotePayment } from '../Remote'
import { TransactionOutput, TransactionInput } from '../Transaction'
import { InvalidWalletArguments } from './errors'

export interface WalletInstance {
  getNextReceivingAddress: () => Promise<Address>
  getNextChangeAddress: () => Promise<Address>
  balance: () => Promise<number>
  transactions: () => Promise<{ id: string, inputs: TransactionInput[], outputs: TransactionOutput[], status?: string }[]>
  selectInputsForTransaction: (paymentOutputs: TransactionOutput[], feeAlgorithm?: FeeAlgorithm) => Promise<TransactionSelection>
  createAndSignTransaction: (payments: RemotePayment[], passphrase: string) => Promise<{ id: string, inputs: TransactionInput[], outputs: TransactionOutput[] }>
}

type WalletConstructor = (walletInstanceArgs: { publicParentKey?: string, walletId?: string }) => WalletInstance

export function Wallet (cardano: Cardano, provider: Provider): WalletConstructor {
  if (provider.type === ProviderType.cardano) {
    return ({ publicParentKey }) => {
      if (!publicParentKey) {
        throw new InvalidWalletArguments(provider.type, 'publicParentKey')
      }

      return ClientWallet(cardano, <CardanoProvider>provider, publicParentKey)
    }
  } else {
    return ({ walletId }) => {
      if (!walletId) {
        throw new InvalidWalletArguments(provider.type, 'walletId')
      }

      return RemoteWallet(<WalletProvider>provider, walletId)
    }
  }
}
