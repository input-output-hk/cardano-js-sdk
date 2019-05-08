import { Provider } from '../../Provider'

let mockUtxoSet: { utxo: string, balance: string }[] = []
export function seedUtxoSet (utxos: { utxo: string, balance: string }[]) {
  mockUtxoSet = utxos
}

export const mockProvider: Provider = {
  submitTransaction: (_signedTransaction) => true,
  queryUtxo: (utxos) => mockUtxoSet.filter(({ utxo }) => utxos.includes(utxo))
}
