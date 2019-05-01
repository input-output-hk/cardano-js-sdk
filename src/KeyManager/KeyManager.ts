import { Key } from './Key'
import { KeyType } from './KeyType'
import { Transaction as CardanoTransaction } from 'cardano-wallet'
import { InvalidKeyType } from './errors'
import MemoryKey from './MemoryKey'

export function KeyManager(keyType: KeyType, key: Key): {
  signTransaction: (transaction: CardanoTransaction) => string
  signMessage: (message: string) => string
} {
  switch (keyType) {
    case KeyType.memory:
      return {
        signTransaction: MemoryKey.signTransaction.bind(null, key),
        signMessage: MemoryKey.signMessage
      }
    default:
      throw new InvalidKeyType()
  }
}

export const CreateMemoryKey = MemoryKey.create
export const GenerateMnemonic = MemoryKey.generateMnemonic