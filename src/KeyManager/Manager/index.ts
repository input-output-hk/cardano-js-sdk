import { KeyInterface } from '../KeyInterface'
import { KeyAccess } from '../KeyAccess'
import { Transaction as CardanoTransaction, BlockchainSettings as CardanoBlockchainSettings } from 'cardano-wallet'
import { InvalidKeyType } from '../errors'
import MemoryKey from '../MemoryKey'
import { getBindingsForEnvironment } from '../../lib/bindings'
import { AddressType } from '../../Wallet'
import { TransactionInput } from '../../Transaction'
const { BlockchainSettings } = getBindingsForEnvironment()

export default function KeyManager (keyAccess: KeyAccess, key: KeyInterface): {
  signTransaction: (transaction: CardanoTransaction, inputs: TransactionInput[], chainSettings?: CardanoBlockchainSettings) => string
  signMessage: (addressType: AddressType, signingIndex: number, message: string) => string
} {
  switch (keyAccess) {
    case KeyAccess.memory:
      return {
        signTransaction: (transaction: CardanoTransaction, inputs: TransactionInput[], chainSettings = BlockchainSettings.mainnet()) => MemoryKey.signTransaction(key, transaction, inputs, chainSettings),
        signMessage: (addressType: AddressType, signingIndex: number, message: string) => MemoryKey.signMessage(key, addressType, signingIndex, message)
      }
    default:
      throw new InvalidKeyType()
  }
}
