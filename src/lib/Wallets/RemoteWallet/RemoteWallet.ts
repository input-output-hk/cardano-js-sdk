import { WalletProvider } from '../../../Provider'
import { WalletInstance, Address, UnsupportedWalletOperation } from '../../../Wallet'
import { TransactionInput, TransactionOutput } from '../../../Transaction'
import { RemoteUnit, RemoteTransaction, RemoteAddressState } from '../../../Remote'

function convertUnitToLovelace (unit: RemoteUnit, value: number): number {
  return unit === RemoteUnit.lovelace ? value : value * 1000000
}

export function RemoteWallet (walletProvider: WalletProvider, walletId: string): WalletInstance {
  return {
    getNextReceivingAddress: async () => {
      const addresses = await walletProvider.addresses(walletId, RemoteAddressState.unused)
      // INFO: I now see some issues with our Address interface
      // We pass around references to account, isChange and key indeces,
      // but maybe we should just scan for this when we go to create
      // tx witnesses from client side keys to improve compatibility with multiple wallet types
      // Issue: https://github.com/input-output-hk/cardano-js-sdk/issues/34
      return { address: addresses[0].id } as Address
    },
    getNextChangeAddress: () => {
      throw new UnsupportedWalletOperation(
        'remote',
        'getNextChangeAddress',
        'createAndSignTransaction automatically selects change addresses.'
      )
    },
    balance: async () => {
      const remoteWallet = await walletProvider.getWallet(walletId)
      const availableBalance = remoteWallet.balance.available.quantity
      return convertUnitToLovelace(remoteWallet.balance.available.unit, availableBalance)
    },
    transactions: async () => {
      const remoteTransactions = await walletProvider.transactions(walletId)
      return remoteTransactions.map(mapRemoteTransactionToSdkType)
    },
    selectInputsForTransaction: () => {
      throw new UnsupportedWalletOperation(
        'remote',
        'selectInputsForTransaction',
        'createAndSignTransaction automatically selects inputs for a transaction.'
      )
    },
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
          value: String(convertUnitToLovelace(input.amount.unit, input.amount.quantity))
        }
      }
    }),
    outputs: remoteTransaction.outputs.map(output => {
      return {
        address: output.address,
        value: String(convertUnitToLovelace(output.amount.unit, output.amount.quantity))
      }
    }),
    direction: remoteTransaction.direction,
    status: remoteTransaction.status
  }
}
