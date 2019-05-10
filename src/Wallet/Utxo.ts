import { TransactionInput } from '../Transaction'

export interface Utxo {
  address: string
  value: string
  hash: string
}

export type UtxoWithAddressing = Utxo & TransactionInput['addressing']
