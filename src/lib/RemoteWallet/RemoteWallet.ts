import { WalletProvider } from '../../Provider'
import { WalletInstance } from '../../Wallet'

export function RemoteWallet (walletProvider: WalletProvider, walletId: number): WalletInstance {
  return {
    getNextReceivingAddress: () => { throw new Error('Unsupported remote wallet operation. This feature is required.') },
    getNextChangeAddress: () => { throw new Error('Unsupported remote wallet operation. createAndSignTransaction automatically selects change addresses.') },
    balance: async () => {
      // TODO
      return 1
    },
    transactions: async () => {
      // TODO
      return [{}]
    },
    selectInputsForTransaction: () => { throw new Error('Unsupported remote wallet operation. createAndSignTransaction automatically selects inputs for a transaction.') },
    createAndSignTransaction: async (payments, passphrase) => {
      // TODO
    }
  }
}
