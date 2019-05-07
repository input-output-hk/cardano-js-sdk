export function Api (_uri: string) {
  return {
    submitTransaction: (_signedTransaction: string) => new Error('Not yet implemented'),
    queryUtxo: (_utxos: string[]) => new Error('Not yet implemented')
  }
}
