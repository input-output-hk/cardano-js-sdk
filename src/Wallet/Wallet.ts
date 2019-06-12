import { TransactionOutput } from '../Transaction'
import { Provider } from '../Provider'
import { AddressType, UtxoWithAddressing } from '.'
import { deriveAddressSet, getNextAddressByType } from './lib'
import { FeeAlgorithm, RustCardano } from '../Cardano'

export function Wallet (provider: Provider, cardano = RustCardano) {
  return (account: string) => {
    return {
      getNextReceivingAddress: () => getNextAddressByType(provider, account, AddressType.external),
      getNextChangeAddress: () => getNextAddressByType(provider, account, AddressType.internal),
      balance: async () => {
        const addresses = await deriveAddressSet(provider, account)
        const utxos = await provider.queryUtxosByAddress(addresses.map(({ address }) => address))
        return utxos.reduce((accumulatedBalance, utxo) => accumulatedBalance + Number(utxo.value), 0)
      },
      transactions: async () => {
        const addresses = await deriveAddressSet(provider, account)
        return provider.queryTransactionsByAddress(addresses.map(({ address }) => address))
      },
      selectInputsForTransaction: async (paymentOutputs: TransactionOutput[], feeAlgorithm = FeeAlgorithm.default) => {
        const addresses = await deriveAddressSet(provider, account)
        const utxos = await provider.queryUtxosByAddress(addresses.map(({ address }) => address))
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

        const nextChangeAddress = await getNextAddressByType(provider, account, AddressType.internal)
        return cardano.inputSelection(paymentOutputs, utxosMappedWithAddresses, nextChangeAddress.address, feeAlgorithm)
      }
    }
  }
}
