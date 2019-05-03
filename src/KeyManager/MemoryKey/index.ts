import { validateMnemonic, generateMnemonic } from 'bip39'
import { InvalidMnemonic } from '../errors'
import { getBindingsForEnvironment } from '../../lib/bindings'
import { AddressType } from '../../Wallet'
import { KeyManager } from '../KeyManager'
const { AccountIndex, AddressKeyIndex, BlockchainSettings, Bip44RootPrivateKey, Entropy, TransactionFinalized, Witness } = getBindingsForEnvironment()

const HARD_DERIVATION_START = 0x80000000

export default function MemoryKeyManager ({ password, accountNumber, mnemonic }: { password: string, accountNumber?: number, mnemonic?: string }): KeyManager {
  if (!mnemonic) {
    mnemonic = generateMnemonic()
  }

  if (!accountNumber) {
    accountNumber = 0
  }

  const validMnemonic = validateMnemonic(mnemonic)
  if (!validMnemonic) throw new InvalidMnemonic()

  const entropy = Entropy.from_english_mnemonics(mnemonic)
  const privateKey = Bip44RootPrivateKey.recover(entropy, password)
  const key = privateKey.bip44_account(AccountIndex.new(accountNumber | HARD_DERIVATION_START))

  return {
    signTransaction: (transaction, rawInputs, chainSettings = BlockchainSettings.mainnet()) => {
      const transactionId = transaction.id()
      const transactionFinalizer = new TransactionFinalized(transaction)

      rawInputs.forEach(({ addressing }) => {
        const privateKey = key.address_key(addressing.change === 1, AddressKeyIndex.new(addressing.index))
        const witness = Witness.new_extended_key(chainSettings, privateKey, transactionId)
        transactionFinalizer.add_witness(witness)
      })

      return transactionFinalizer.finalize().to_hex()
    },
    signMessage: (addressType, signingIndex, message) => {
      const privateKey = key.address_key(addressType === AddressType.internal, AddressKeyIndex.new(signingIndex))
      return privateKey.sign(Buffer.from(message)).to_hex()
    },
    publicAccount: () => key.public()
  }
}
