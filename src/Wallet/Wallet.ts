import { TransactionOutput } from '../Transaction'
import { Provider } from '../Provider'
import { AddressType, UtxoWithAddressing } from '.'
import { deriveAddressSet, getNextAddressByType } from './lib'
import { FeeAlgorithm, Cardano } from '../Cardano'

export function Wallet (cardano: Cardano, provider: Provider) {
  return (account: string) => {
    return {
      getNextReceivingAddress: () => getNextAddressByType(cardano, provider, account, AddressType.external),
      getNextChangeAddress: () => getNextAddressByType(cardano, provider, account, AddressType.internal),
      balance: async () => {
        const addresses = await deriveAddressSet(cardano, provider, account)
        const utxos = await provider.queryUtxosByAddress(addresses.map(({ address }) => address))
        return utxos.reduce((accumulatedBalance, utxo) => accumulatedBalance + Number(utxo.value), 0)
      },
      transactions: async () => {
        const addresses = await deriveAddressSet(cardano, provider, account)
        return provider.queryTransactionsByAddress(addresses.map(({ address }) => address))
      },
      selectInputsForTransaction: async (paymentOutputs: TransactionOutput[], feeAlgorithm = FeeAlgorithm.default) => {
        const addresses = await deriveAddressSet(cardano, provider, account)
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

        const nextChangeAddress = await getNextAddressByType(cardano, provider, account, AddressType.internal)
        return cardano.inputSelection(paymentOutputs, utxosMappedWithAddresses, nextChangeAddress.address, feeAlgorithm)
      }
    }
  }
}
