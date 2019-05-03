import { generateMnemonic, validateMnemonic } from 'bip39'
import { BlockchainSettings, Bip44AccountPrivate } from 'cardano-wallet'
import { InvalidMnemonic } from '../errors'
import { getBindingsForEnvironment } from '../../lib/bindings'
import { AddressType } from '../../Wallet'
import { KeyManager } from '../KeyManager'
const { AccountIndex, AddressKeyIndex, Bip44RootPrivateKey, Entropy, TransactionFinalized, Witness } = getBindingsForEnvironment()

const HARD_DERIVATION_START = 0x80000000

interface MemoryKey extends KeyManager {
  generateMnemonic: () => string,
  create: (mnemonic: string, password: string, accountNumber?: number) => Bip44AccountPrivate
}

const memoryKey: MemoryKey = {
  generateMnemonic,
  create: (mnemonic, password, accountNumber = 0) => {
    const validMnemonic = validateMnemonic(mnemonic)
    if (!validMnemonic) throw new InvalidMnemonic()

    const entropy = Entropy.from_english_mnemonics(mnemonic)
    const privateKey = Bip44RootPrivateKey.recover(entropy, password)
    return privateKey.bip44_account(AccountIndex.new(accountNumber | HARD_DERIVATION_START))
  },
  signTransaction: (key, transaction, rawInputs, chainSettings = BlockchainSettings.mainnet()) => {
    const transactionId = transaction.id()
    const transactionFinalizer = new TransactionFinalized(transaction)

    rawInputs.forEach(({ addressing }) => {
      const privateKey = key.address_key(addressing.change === 1, AddressKeyIndex.new(addressing.index))
      const witness = Witness.new_extended_key(chainSettings, privateKey, transactionId)
      transactionFinalizer.add_witness(witness)
    })

    return transactionFinalizer.finalize().to_hex()
  },
  signMessage: (key, addressType, signingIndex, message) => {
    const privateKey = key.address_key(addressType === AddressType.internal, AddressKeyIndex.new(signingIndex))
    return privateKey.sign(Buffer.from(message)).to_hex()
  }
}

export default memoryKey
