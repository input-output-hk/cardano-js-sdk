import { validateMnemonic } from 'bip39'
import { InvalidMnemonic } from '../errors'
import { KeyManager } from '../KeyManager'
import { ChainSettings, RustCardano } from '../../Cardano'

export function InMemoryKeyManager (
  { password, accountIndex, mnemonic }: {
    password: string
    accountIndex?: number
    mnemonic: string
  }, cardano = RustCardano): KeyManager {
  if (!accountIndex) {
    accountIndex = 0
  }

  const validMnemonic = validateMnemonic(mnemonic)
  if (!validMnemonic) throw new InvalidMnemonic()

  const { privateParentKey, publicParentKey } = cardano.account(mnemonic, password, accountIndex)

  return {
    signTransaction: async (transaction, rawInputs, chainSettings = ChainSettings.mainnet) => {
      rawInputs.forEach(({ addressing }) => {
        transaction.addWitness({ privateParentKey: privateParentKey, addressing, chainSettings })
      })

      return transaction.finalize()
    },
    signMessage: async (addressType, signingIndex, message) => {
      return cardano.signMessage({ privateParentKey: privateParentKey, addressType, signingIndex, message })
    },
    publicParentKey: async () => publicParentKey
  }
}
