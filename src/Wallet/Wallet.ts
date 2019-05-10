import { Bip44AccountPublic } from 'cardano-wallet'
import { TransactionOutput } from '../Transaction'
import { Provider } from '../Provider'
import { AddressType, UtxoWithAddressing } from '.'
import { deriveAddressSet, getNextAddressByType, selectInputsAndChangeOutput } from './lib'

export enum InputSelectionAlgorithm {
  largestFirst = 'largestFirst',
  random = 'random'
}

export function Wallet (provider: Provider) {
  return (account: Bip44AccountPublic) => {
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
      selectInputsForTransaction: async (paymentOutputs: TransactionOutput[], fee: string, selectionAlgorithm = InputSelectionAlgorithm.random) => {
        const addresses = await deriveAddressSet(provider, account)
        const utxos = await provider.queryUtxosByAddress(addresses.map(({ address }) => address))
        const utxosMappedWithAddresses: UtxoWithAddressing[] = utxos.map(utxo => {
          const { index, type } = addresses.find(({ address }) => address === utxo.address)
          return {
            index,
            change: type === AddressType.internal ? 1 : 0,
            ...utxo
          }
        })

        const paymentValue = paymentOutputs.reduce((value, output) => value + Number(output.value), 0) + Number(fee)
        const nextChangeAddress = await getNextAddressByType(provider, account, AddressType.internal)

        return selectInputsAndChangeOutput(paymentValue, utxosMappedWithAddresses, nextChangeAddress.address, selectionAlgorithm)
      }
    }
  }
}
