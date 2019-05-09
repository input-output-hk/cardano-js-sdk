import { TransactionInput, TransactionOutput } from '../../Transaction'

export interface Utxo {
  address: string
  value: string
}

export interface TransactionSelection {
  inputs: TransactionInput[]
  changeOutput: TransactionOutput
}

export function largestFirst(paymentValue: number, utxoSet: Utxo[]): TransactionSelection {
  return {} as any
}

export function random(paymentValue: number, utxoSet: Utxo[]): TransactionSelection {
  return {} as any
}

export function randomImprove(paymentValue: number, utxoSet: Utxo[]): TransactionSelection {
  return {} as any
}