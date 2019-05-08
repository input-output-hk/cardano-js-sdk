import Transaction from './Transaction'
import Wallet from './Wallet'
import { Provider, HttpProvider } from './Provider'
import * as Utils from './Utils'
import { InMemoryKeyManager } from './KeyManager'

export { Transaction, InMemoryKeyManager, Utils }

export const providers: { [provider: string]: (connection: string) => Provider } = {
  http: HttpProvider
}

export function connect (provider: Provider) {
  return {
    wallet: Wallet(provider),
    ...provider
  }
}
