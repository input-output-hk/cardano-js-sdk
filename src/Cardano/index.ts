import { TransactionInput, TransactionOutput } from '../Transaction'
import { FeeAlgorithm } from './FeeAlgorithm'
import { Transaction } from './Transaction'
import { AddressType, Address, UtxoWithAddressing } from '../Wallet'
import { ChainSettings } from './ChainSettings'
import { TransactionSelection } from './TransactionSelection'

export { RustCardano } from './lib/RustCardano'
export { FeeAlgorithm }
export { ChainSettings }
export { TransactionSelection }
export interface Cardano {
  buildTransaction: (
    inputs: TransactionInput[],
    outputs: TransactionOutput[],
    feeAlgorithm?: FeeAlgorithm
  ) => Transaction
  account: (
    mnemonic: string,
    passphrase: string,
    accountIndex: number
  ) => { privateParentKey: string, publicParentKey: string }
  address: (
    args: {
      publicParentKey: string,
      index: number,
      type: AddressType
      accountIndex: number
    },
    chainSettings?: ChainSettings
  ) => Address
  signMessage: (
    args: {
      privateParentKey: string
      addressType: AddressType
      signingIndex: number
      message: string
    }
  ) => { signature: string, publicKey: string }
  verifyMessage: (
    args: {
      publicKey: string
      message: string
      signature: string
    }
  ) => boolean
  inputSelection: (
    outputs: TransactionOutput[],
    utxoSet: UtxoWithAddressing[],
    changeAddress: string,
    feeAlgorithm?: FeeAlgorithm
  ) => TransactionSelection
}
