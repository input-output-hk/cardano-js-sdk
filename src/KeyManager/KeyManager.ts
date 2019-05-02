import { Key } from './Key'
import { KeyType } from './KeyType'
import { Transaction as CardanoTransaction, BlockchainSettings as CardanoBlockchainSettings } from 'cardano-wallet'
import { InvalidKeyType } from './errors'
import MemoryKey from './MemoryKey'
import { getBindingsForEnvironment } from '../lib/bindings'
import { AddressType } from '../Wallet'
const { BlockchainSettings } = getBindingsForEnvironment()

export function KeyManager (keyType: KeyType, key: Key): {
  signTransaction: (transaction: CardanoTransaction, chainSettings: CardanoBlockchainSettings) => string
  signMessage: (addressType: AddressType, signingIndex: number, message: string) => string
} {
  switch (keyType) {
    case KeyType.memory:
      return {
        signTransaction: (transaction: CardanoTransaction, chainSettings = BlockchainSettings.mainnet()) => MemoryKey.signTransaction(key, transaction, chainSettings),
        signMessage: (addressType: AddressType, signingIndex: number, message: string) => MemoryKey.signMessage(key, addressType, signingIndex, message)
      }
    default:
      throw new InvalidKeyType()
  }
}

export const CreateMemoryKey = MemoryKey.create
export const GenerateMnemonic = MemoryKey.generateMnemonic
