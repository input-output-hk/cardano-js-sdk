import { Provider, CardanoProvider, WalletProvider, ProviderType } from '../Provider'
import { Cardano, FeeAlgorithm, TransactionSelection, ChainSettings } from '../Cardano'
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

type WalletConstructor = (walletInstanceArgs: { publicParentKey?: string, chainSettings?: ChainSettings, walletId?: string }) => WalletInstance

export function Wallet (cardano: Cardano, provider: Provider): WalletConstructor {
  if (provider.type === ProviderType.cardano) {
    return ({ publicParentKey, chainSettings }) => {
      if (!publicParentKey) {
        throw new InvalidWalletArguments(provider.type, 'publicParentKey')
      }

      if (!chainSettings) {
        chainSettings = ChainSettings.mainnet
      }

      return ClientWallet(cardano, <CardanoProvider>provider, publicParentKey, chainSettings)
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
