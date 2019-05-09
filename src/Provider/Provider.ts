import { TransactionInput, TransactionOutput } from '../Transaction'

export type SubmitTransaction = (signedTransaction: string) => Promise<boolean>
export type QueryUtxosByAddress = (addresses: string[]) => Promise<{ address: string, value: string }[]>
export type QueryTransactionsByAddress = (addresses: string[]) => Promise<{ inputs: TransactionInput[], outputs: TransactionOutput[] }[]>

export interface Provider {
  submitTransaction: SubmitTransaction
  queryUtxosByAddress: QueryUtxosByAddress
  queryTransactionsByAddress: QueryTransactionsByAddress
}
