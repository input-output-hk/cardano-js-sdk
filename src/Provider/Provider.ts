export type SubmitTransaction = (signedTransaction: string) => boolean
export type QueryUtxo = (utxos: string[]) => { utxo: string, balance: string }[]

export interface Provider {
  submitTransaction: SubmitTransaction
  queryUtxo: QueryUtxo
}
