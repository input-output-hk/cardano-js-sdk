import Transaction from './Transaction'
import Wallet from './Wallet'
import { Provider, SubmitTransaction, QueryUtxo } from './Provider'
import * as utils from './utils'
import { MemoryKeyManager } from './KeyManager'

export default class CardanoSdk implements Provider {
  public static Transaction = Transaction
  public static MemoryKeyManager = MemoryKeyManager
  public static Wallet = Wallet
  public static utils = utils

  public submitTransaction: SubmitTransaction;
  public queryUtxo: QueryUtxo;

  constructor (provider: Provider) {
    this.submitTransaction = provider.submitTransaction
    this.queryUtxo = provider.queryUtxo
  }
}
