import { CardanoProvider } from '../../Provider'

export function ClientHttpProvider (_uri: string): CardanoProvider {
  // To be implemented by: https://github.com/input-output-hk/cardano-js-sdk/issues/4
  // This will likely convert this interface to interact with Jormangandr and remove the any
  // type casting
  return {
    submitTransaction: (_signedTransaction: string) => new Error('Not yet implemented'),
    queryUtxo: (_utxos: string[]) => new Error('Not yet implemented')
  } as any
}
