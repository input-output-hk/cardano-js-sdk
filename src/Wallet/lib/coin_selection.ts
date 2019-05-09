import { TransactionInput, TransactionOutput } from '../../Transaction'

export interface Utxo {
  address: string
  value: string
  hash: string
}

export interface TransactionSelection {
  inputs: TransactionInput[]
  changeOutput: TransactionOutput
}

export function largestFirst (_paymentValue: number, _utxoSet: (Utxo & TransactionInput['addressing'])[]): TransactionSelection {
  return {} as any
}

export function random (_paymentValue: number, _utxoSet: (Utxo & TransactionInput['addressing'])[]): TransactionSelection {
  return {} as any
}

export function randomImprove (_paymentValue: number, _utxoSet: (Utxo & TransactionInput['addressing'])[]): TransactionSelection {
  return {} as any
}
