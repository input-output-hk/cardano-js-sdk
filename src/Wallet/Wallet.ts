import { Bip44AccountPublic } from 'cardano-wallet'
import { TransactionOutput } from '../Transaction'
import { Provider } from '../Provider'
import { AddressType } from '.'
import { deriveCurrentAddressSet, getNextAddressByType, largestFirst, random, randomImprove, Utxo, TransactionSelection } from './lib'


export enum InputSelectionAlgorithm {
  largestFirst = 'largestFirst',
  random = 'random',
  randomImprove = 'randomImprove'
}

export function Wallet(provider: Provider) {
  return (account: Bip44AccountPublic) => {
    return {
      getNextReceivingAddress: () => getNextAddressByType(provider, account, AddressType.external),
      getNextChangeAddress: () => getNextAddressByType(provider, account, AddressType.internal),
      balance: async () => {
        const relevantAddresses = await deriveCurrentAddressSet(provider, account)
        const utxos = await provider.queryUtxosByAddress(relevantAddresses)
        return utxos.reduce((accumulatedBalance, utxo) => accumulatedBalance + Number(utxo.value), 0)
      },
      transactions: async () => {
        const relevantAddresses = await deriveCurrentAddressSet(provider, account)
        return provider.queryTransactionsByAddress(relevantAddresses)
      },
      selectInputsForTransaction: async (paymentOutputs: TransactionOutput[], fee: string, selectionAlgorithm = InputSelectionAlgorithm.random) => {
        const relevantAddresses = await deriveCurrentAddressSet(provider, account)
        const utxos = await provider.queryUtxosByAddress(relevantAddresses)
        const paymentValue = paymentOutputs.reduce((value, output) => value + Number(output.value), 0) + Number(fee)

        const caller: { [algorithm: string]: (paymentValue: number, utxoSet: Utxo[]) => TransactionSelection } = {
          [InputSelectionAlgorithm.largestFirst]: largestFirst,
          [InputSelectionAlgorithm.random]: random,
          [InputSelectionAlgorithm.randomImprove]: randomImprove,
        }

        return caller[selectionAlgorithm](paymentValue, utxos)
      }
    }
  }
}