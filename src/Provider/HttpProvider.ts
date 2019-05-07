import { Provider } from '.'

export function HttpProvider (_uri: string): Provider {
  return {
    submitTransaction: (_signedTransaction: string) => new Error('Not yet implemented'),
    queryUtxo: (_utxos: string[]) => new Error('Not yet implemented')
  } as any
}
