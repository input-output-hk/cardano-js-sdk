import { BaseProvider } from './BaseProvider'
import { RemotePayment, RemoteWallet, RemoteTransaction, RemoteAddressState, RemoteAddress } from '../Remote'

export interface WalletProvider extends BaseProvider {
  wallets: () => Promise<RemoteWallet[]>
  createWallet: (createWalletArgs: {
    name: string
    mnemonic: string
    mnemonicSecondFactor?: string
    passphrase: string
  }) => Promise<RemoteWallet>
  getWallet: (walletId: string) => Promise<RemoteWallet>
  transactions: (walletId: string, startDate?: Date, endDate?: Date) => Promise<RemoteTransaction[]>
  createTransaction: (walletId: string, payments: RemotePayment[], passphrase: string) => Promise<RemoteTransaction>
  addresses: (walletId: string, state: RemoteAddressState) => Promise<RemoteAddress[]>
}
