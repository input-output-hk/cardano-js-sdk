import { validateMnemonic } from 'bip39'
import { InvalidMnemonic } from '../errors'
import { KeyManager } from '../KeyManager'
import { ChainSettings, RustCardano } from '../../Cardano'

export function InMemoryKeyManager(
  { password, accountNumber, mnemonic }: {
    password: string
    accountNumber?: number
    mnemonic: string
  }, cardano = RustCardano): KeyManager {
  if (!accountNumber) {
    accountNumber = 0
  }

  const validMnemonic = validateMnemonic(mnemonic)
  if (!validMnemonic) throw new InvalidMnemonic()

  const { privateKey, publicKey } = cardano.account(mnemonic, password, accountNumber)

  return {
    signTransaction: async (transaction, rawInputs, chainSettings = ChainSettings.mainnet) => {
      rawInputs.forEach(({ addressing }) => {
        transaction.addWitness({ privateAccount: privateKey, addressing, chainSettings })
      })

      return transaction.finalize()
    },
    signMessage: async (addressType, signingIndex, message) => {
      return cardano.signMessage({ privateAccount: privateKey, addressType, signingIndex, message })
    },
    publicAccount: async () => publicKey
  }
}
