import { TransactionInput, TransactionOutput } from '../../Transaction'
import { InsufficientValueInUtxosForSelection } from '../errors'

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

export function largestFirst (paymentValue: number, utxoSet: UtxoWithAddressing[], changeAddress: string): TransactionSelection {
  const sortedUtxo = utxoSet.sort((a, b) => Number(b.value) - Number(a.value))
  const { paymentAccumulated, utxos }: { paymentAccumulated: number, utxos: UtxoWithAddressing[] } = sortedUtxo.reduce((accumulator, utxo) => {
    if (accumulator.paymentAccumulated < paymentValue) {
      accumulator.paymentAccumulated = accumulator.paymentAccumulated + Number(utxo.value)
      accumulator.utxos.push(utxo)
    }

    return accumulator
  }, { paymentAccumulated: 0, utxos: [] })

  if (paymentAccumulated < paymentValue) {
    throw new InsufficientValueInUtxosForSelection(paymentValue, paymentAccumulated)
  }

  const inputs = createTransactionInputsForUtxos(utxos)

  let changeOutput
  if (paymentAccumulated > paymentValue) {
    changeOutput = createChangeOutput(changeAddress, paymentValue, paymentAccumulated)
  }

  return { inputs, changeOutput }
}

export function random (_paymentValue: number, _utxoSet: UtxoWithAddressing[], _changeAddress: string): TransactionSelection {
  return {} as any
}

export function randomImprove (_paymentValue: number, _utxoSet: UtxoWithAddressing[], _changeAddress: string): TransactionSelection {
  return {} as any
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
