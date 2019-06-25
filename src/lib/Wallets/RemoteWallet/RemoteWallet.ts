import { WalletProvider } from '../../../Provider'
import { WalletInstance } from '../../../Wallet'
import { TransactionInput, TransactionOutput } from '../../../Transaction'
import { RemoteUnit, RemoteTransaction } from '../../../Remote'

export function RemoteWallet (walletProvider: WalletProvider, walletId: string): WalletInstance {
  return {
    getNextReceivingAddress: () => { throw new Error('Currently unsupported. This feature is required but lacks the upstream dependency.') },
    getNextChangeAddress: () => { throw new Error('Unsupported remote wallet operation. createAndSignTransaction automatically selects change addresses.') },
    balance: async () => {
      const remoteWallet = await walletProvider.getWallet(walletId)
      const availableBalance = remoteWallet.balance.available.quantity
      return remoteWallet.balance.available.unit === RemoteUnit.lovelace ? availableBalance : availableBalance * 1000000
    },
    transactions: async () => {
      const remoteTransactions = await walletProvider.transactions(walletId)
      return remoteTransactions.map(mapRemoteTransactionToSdkType)
    },
    selectInputsForTransaction: () => { throw new Error('Unsupported remote wallet operation. createAndSignTransaction automatically selects inputs for a transaction.') },
    createAndSignTransaction: async (payments, passphrase) => {
      const newRemoteTransaction = await walletProvider.createTransaction(walletId, payments, passphrase)
      return mapRemoteTransactionToSdkType(newRemoteTransaction)
    }
  }
}

function mapRemoteTransactionToSdkType (remoteTransaction: RemoteTransaction): { id: string, inputs: TransactionInput[], outputs: TransactionOutput[] } {
  return {
    id: remoteTransaction.id,
    inputs: remoteTransaction.inputs.map((input, index) => {
      return {
        pointer: {
          index,
          id: remoteTransaction.id
        },
        value: {
          address: input.address,
          value: input.amount.unit === RemoteUnit.lovelace
            ? String(input.amount.quantity)
            : String(input.amount.quantity * 1000000)
        }
      }
    }),
    outputs: remoteTransaction.outputs.map(output => {
      return {
        address: output.address,
        value: output.amount.unit === RemoteUnit.lovelace
          ? String(output.amount.quantity)
          : String(output.amount.quantity * 1000000)
      }
    })
  }
}
