import { TransactionInput } from '../Transaction'

export interface Utxo {
  address: string
  value: string
  id: string
  index: number
}

export interface UtxoWithAddressing extends Utxo {
  addressing: TransactionInput['addressing']
}
