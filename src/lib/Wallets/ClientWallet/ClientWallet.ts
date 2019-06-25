import { Cardano, FeeAlgorithm } from '../../../Cardano'
import { CardanoProvider } from '../../../Provider'
import { getNextAddressByType } from './get_next_address'
import { deriveAddressSet } from './address_derivation'
import { AddressType, UtxoWithAddressing, WalletInstance } from '../../../Wallet'
import { TransactionOutput } from '../../../Transaction'

export function ClientWallet (cardano: Cardano, cardanoProvider: CardanoProvider, account: string): WalletInstance {
  return {
    getNextReceivingAddress: () => getNextAddressByType(cardano, cardanoProvider, account, AddressType.external),
    getNextChangeAddress: () => getNextAddressByType(cardano, cardanoProvider, account, AddressType.internal),
    balance: async () => {
      const addresses = await deriveAddressSet(cardano, cardanoProvider, account)
      const utxos = await cardanoProvider.queryUtxosByAddress(addresses.map(({ address }) => address))
      return utxos.reduce((accumulatedBalance, utxo) => accumulatedBalance + Number(utxo.value), 0)
    },
    transactions: async () => {
      const addresses = await deriveAddressSet(cardano, cardanoProvider, account)
      return cardanoProvider.queryTransactionsByAddress(addresses.map(({ address }) => address))
    },
    selectInputsForTransaction: async (paymentOutputs: TransactionOutput[], feeAlgorithm = FeeAlgorithm.default) => {
      const addresses = await deriveAddressSet(cardano, cardanoProvider, account)
      const utxos = await cardanoProvider.queryUtxosByAddress(addresses.map(({ address }) => address))
      const utxosMappedWithAddresses: UtxoWithAddressing[] = utxos.map(utxo => {
        const { index, type, accountIndex } = addresses.find(({ address }) => address === utxo.address)
        return {
          addressing: {
            index,
            change: type === AddressType.internal ? 1 : 0,
            accountIndex
          },
          ...utxo
        }
      })

      const nextChangeAddress = await getNextAddressByType(cardano, cardanoProvider, account, AddressType.internal)
      return cardano.inputSelection(paymentOutputs, utxosMappedWithAddresses, nextChangeAddress.address, feeAlgorithm)
    },
    createAndSignTransaction: () => { throw new Error('Unsupported Client wallet operation. Instead use the Transaction interface to build the transaction, and KeyManager to sign it.') }
  }
}
