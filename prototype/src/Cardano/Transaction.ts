import { TransactionInput } from '../Transaction'
import { AddressType } from '../Wallet'
import { ChainSettings } from './ChainSettings'

export interface Transaction {
  toHex: () => string
  toJson: () => any
  id: () => string
  addWitness: (args: { privateParentKey: string, addressing: TransactionInput['addressing'], chainSettings?: ChainSettings }) => void
  addExternalWitness: (args: { publicParentKey: string, addressType: AddressType, witnessIndex: number, witnessHex: string }) => void
  finalize: () => string
  fee: () => string
  estimateFee?: () => string
}
