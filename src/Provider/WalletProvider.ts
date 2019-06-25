import { BaseProvider } from './BaseProvider'

export interface WalletProvider extends BaseProvider {
  wallets: Function
  createWallet: Function
  transactions: Function
  createTransaction: Function
}
