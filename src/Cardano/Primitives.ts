import { TransactionInput, TransactionOutput } from '../Transaction'
import { Address, AddressType, UtxoWithAddressing } from '../Wallet'

export interface Transaction {
  toHex: () => string
  toJson: () => any
  id: () => string
  addWitness: (args: { privateAccount: string, addressing: TransactionInput['addressing'], chainSettings?: ChainSettings }) => void
  addExternalWitness: (args: { publicAccount: string, addressType: AddressType, witnessIndex: number, witnessHex: string }) => void
  finalize: () => string
  fee: () => string
  estimateFee?: () => string
}

export enum FeeAlgorithm {
  default = 'default'
}

export enum ChainSettings {
  mainnet = 'mainnet',
}

export interface TransactionSelection {
  inputs: TransactionInput[]
  changeOutput: TransactionOutput
}

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
  ) => { privateKey: string, publicKey: string }
  address: (
    args: {
      publicAccount: string,
      index: number,
      type: AddressType
    },
    chainSettings?: ChainSettings
  ) => Address
  signMessage: (
    args: {
      privateAccount: string
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