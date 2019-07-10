import { BaseProvider } from './BaseProvider'
import { Utxo } from '../Wallet'
import { TransactionInput, TransactionOutput } from '../Transaction'

export type SubmitTransaction = (signedTransaction: string) => Promise<boolean>
export type QueryUtxosByAddress = (addresses: string[]) => Promise<Utxo[]>
export type QueryTransactionsByAddress = (addresses: string[]) => Promise<{ id: string, inputs: TransactionInput[], outputs: TransactionOutput[] }[]>
export type QueryTransactionsById = (ids: string[]) => Promise<any[]>

export interface CardanoProvider extends BaseProvider {
  submitTransaction: SubmitTransaction
  queryUtxosByAddress: QueryUtxosByAddress
  queryTransactionsByAddress: QueryTransactionsByAddress
  queryTransactionsById: QueryTransactionsById
}
