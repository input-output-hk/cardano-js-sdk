import { TransactionInput, TransactionOutput } from '../../Transaction'
import { InsufficientValueInUtxosForSelection, MaximumTransactionInputsExceeded } from '../errors'
import { getRandomBytesForEnvironmentAsHex } from '../../lib/bindings'
import { MAX_TRANSACTION_INPUTS } from '../config'
import { InputSelectionAlgorithm } from '../Wallet'

export interface Utxo {
  address: string
  value: string
  hash: string
}

export type UtxoWithAddressing = Utxo & TransactionInput['addressing']

export interface TransactionSelection {
  inputs: TransactionInput[]
  changeOutput: TransactionOutput
}

function largestFirstUtxoSort (utxoSet: UtxoWithAddressing[]) {
  return utxoSet.sort((a, b) => Number(b.value) - Number(a.value))
}

function randomUtxoSort (utxoSet: UtxoWithAddressing[]) {
  const utxoSetWithRandomBytes = utxoSet.map(utxo => {
    const randomBytes = getRandomBytesForEnvironmentAsHex()
    return {
      randomBytes,
      ...utxo
    }
  })

  return utxoSetWithRandomBytes.sort((a, b) => a.randomBytes > b.randomBytes ? 1 : -1)
}

export function selectInputsAndChangeOutput (paymentValue: number, utxoSet: UtxoWithAddressing[], changeAddress: string, selectionAlgo: InputSelectionAlgorithm): TransactionSelection {
  const sortedUtxoSet = selectionAlgo === InputSelectionAlgorithm.random
    ? randomUtxoSort(utxoSet)
    : largestFirstUtxoSort(utxoSet)

  const { paymentAccumulated, utxos } = accumulateUtxos(paymentValue, sortedUtxoSet)

  if (paymentAccumulated < paymentValue) {
    throw new InsufficientValueInUtxosForSelection(paymentValue, paymentAccumulated)
  }

  if (selectionAlgo === InputSelectionAlgorithm.random && utxos.length > MAX_TRANSACTION_INPUTS) {
    return selectInputsAndChangeOutput(paymentValue, utxoSet, changeAddress, InputSelectionAlgorithm.largestFirst)
  }

  if (utxos.length > MAX_TRANSACTION_INPUTS) {
    throw new MaximumTransactionInputsExceeded(MAX_TRANSACTION_INPUTS, utxos.length)
  }

  const inputs = createTransactionInputsForUtxos(utxos)

  let changeOutput
  if (paymentAccumulated > paymentValue) {
    changeOutput = createChangeOutput(changeAddress, paymentValue, paymentAccumulated)
  }

  return { inputs, changeOutput }
}

function accumulateUtxos (paymentValue: number, sortedUtxo: UtxoWithAddressing[]): { paymentAccumulated: number, utxos: UtxoWithAddressing[] } {
  return sortedUtxo.reduce((accumulator, utxo) => {
    if (accumulator.paymentAccumulated < paymentValue) {
      accumulator.paymentAccumulated = accumulator.paymentAccumulated + Number(utxo.value)
      accumulator.utxos.push(utxo)
    }

    return accumulator
  }, { paymentAccumulated: 0, utxos: [] })
}

function createTransactionInputsForUtxos (utxoSet: UtxoWithAddressing[]) {
  return utxoSet.map((utxo, index) => {
    return {
      pointer: {
        id: utxo.hash,
        index
      },
      value: {
        address: utxo.address,
        value: utxo.value
      },
      addressing: {
        index: utxo.index,
        change: 0
      }
    }
  })
}

function createChangeOutput (changeAddress: string, paymentValue: number, paymentAccumulated: number) {
  return {
    address: changeAddress,
    value: String(paymentAccumulated - paymentValue)
  }
}
