import { TransactionInput, TransactionOutput } from '../Transaction'
import { Utxo } from '../Wallet'

export type SubmitTransaction = (signedTransaction: string) => Promise<boolean>
export type QueryUtxosByAddress = (addresses: string[]) => Promise<Utxo[]>
export type QueryTransactionsByAddress = (addresses: string[]) => Promise<{ inputs: TransactionInput[], outputs: TransactionOutput[] }[]>
export type QueryTransactionsById = (ids: string[]) => Promise<any[]>

export interface Provider {
  submitTransaction: SubmitTransaction
  queryUtxosByAddress: QueryUtxosByAddress
  queryTransactionsByAddress: QueryTransactionsByAddress
  queryTransactionsById: QueryTransactionsById
}
