import { TransactionInput, TransactionOutput } from '../Transaction'

export interface TransactionSelection {
  inputs: TransactionInput[]
  changeOutput: TransactionOutput
}
