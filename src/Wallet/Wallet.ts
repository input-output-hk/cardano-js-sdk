import { TransactionOutput } from '../Transaction'
import { Provider, CardanoProvider, WalletProvider, ProviderType } from '../Provider'
import { AddressType, UtxoWithAddressing } from '.'
import { deriveAddressSet, getNextAddressByType } from './lib'
import { FeeAlgorithm, Cardano } from '../Cardano'

export function Wallet(cardano: Cardano, provider: Provider) {
  if (provider.type === ProviderType.client) {
    const clientProvider = provider as CardanoProvider

    return (account: string) => {
      return {
        getNextReceivingAddress: () => getNextAddressByType(cardano, clientProvider, account, AddressType.external),
        getNextChangeAddress: () => getNextAddressByType(cardano, clientProvider, account, AddressType.internal),
        balance: async () => {
          const addresses = await deriveAddressSet(cardano, clientProvider, account)
          const utxos = await clientProvider.queryUtxosByAddress(addresses.map(({ address }) => address))
          return utxos.reduce((accumulatedBalance, utxo) => accumulatedBalance + Number(utxo.value), 0)
        },
        transactions: async () => {
          const addresses = await deriveAddressSet(cardano, clientProvider, account)
          return clientProvider.queryTransactionsByAddress(addresses.map(({ address }) => address))
        },
        selectInputsForTransaction: async (paymentOutputs: TransactionOutput[], feeAlgorithm = FeeAlgorithm.default) => {
          const addresses = await deriveAddressSet(cardano, clientProvider, account)
          const utxos = await clientProvider.queryUtxosByAddress(addresses.map(({ address }) => address))
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

          const nextChangeAddress = await getNextAddressByType(cardano, clientProvider, account, AddressType.internal)
          return cardano.inputSelection(paymentOutputs, utxosMappedWithAddresses, nextChangeAddress.address, feeAlgorithm)
        }
      }
    }
  } else {
    return provider as WalletProvider
  }
}
