import Transaction, { TransactionInput, TransactionOutput } from './Transaction'
import Wallet from './Wallet'
import { Provider, HttpProvider } from './Provider'
import * as Utils from './Utils'
import { InMemoryKeyManager, LedgerKeyManager, RustCardano } from './lib'
import { FeeAlgorithm, ChainSettings } from './Cardano'

export const providers: { [provider: string]: (connection: string) => Provider } = {
  http: HttpProvider
}

export default function CardanoSDK (cardano = RustCardano) {
  return {
    Transaction (inputs: TransactionInput[], outputs: TransactionOutput[], feeAlgorithm = FeeAlgorithm.default) {
      return Transaction(cardano, inputs, outputs, feeAlgorithm)
    },
    InMemoryKeyManager (keyArgs: { password: string, accountIndex?: number, mnemonic: string }) {
      return InMemoryKeyManager(cardano, keyArgs)
    },
    LedgerKeyManager,
    Utils: {
      generateMnemonic: Utils.generateMnemonic,
      addressDiscoveryWithinBounds: (addressDiscoveryArgs: Utils.AddressDiscoveryArgs, chainSettings = ChainSettings.mainnet) => {
        return Utils.addressDiscoveryWithinBounds(cardano, addressDiscoveryArgs, chainSettings)
      },
      verifyMessage: cardano.verifyMessage
    },
    connect (provider: Provider) {
      return {
        wallet: Wallet(cardano, provider),
        ...provider
      }
    }
  }
}
