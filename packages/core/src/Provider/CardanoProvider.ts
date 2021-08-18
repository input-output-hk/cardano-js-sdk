
import { Schema as Cardano } from '@cardano-ogmios/client'

export type QueryTransactionsByAddress = (addresses: Cardano.Address[]) => Promise<({ id: string } & Cardano.Tx)[]>
export type QueryTransactionsById = (ids: Cardano.Tx[]) => Promise<any[]>

export interface CardanoProvider {
  submitTx: (signedTransaction: string) => Promise<boolean>
  utxo: (addresses: Cardano.Address[]) => Promise<Cardano.Utxo>
  queryTransactionsByAddress: QueryTransactionsByAddress
  queryTransactionsById: QueryTransactionsById
}
