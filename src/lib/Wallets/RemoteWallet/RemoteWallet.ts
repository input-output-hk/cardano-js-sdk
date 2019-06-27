import { WalletProvider } from '../../../Provider'
import { WalletInstance, Address } from '../../../Wallet'
import { TransactionInput, TransactionOutput } from '../../../Transaction'
import { RemoteUnit, RemoteTransaction, RemoteAddressState } from '../../../Remote'

export function RemoteWallet (walletProvider: WalletProvider, walletId: string): WalletInstance {
  return {
    getNextReceivingAddress: async () => {
      const addresses = await walletProvider.addresses(walletId, RemoteAddressState.unused)
      // TODO: I now see some issues with our address construct
      // We pass around references to account, isChange and indeces,
      // but maybe we should just scan for this when we go to create
      // tx witnesses from client side keys
      return { address: addresses[0].id } as Address
    },
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

function mapRemoteTransactionToSdkType (remoteTransaction: RemoteTransaction): {
  id: string,
  inputs: TransactionInput[],
  outputs: TransactionOutput[]
  direction?: string
  status?: string
} {
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
    }),
    direction: remoteTransaction.direction,
    status: remoteTransaction.status
  }
}
