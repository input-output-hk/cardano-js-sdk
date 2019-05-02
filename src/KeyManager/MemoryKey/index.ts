import { generateMnemonic, validateMnemonic } from 'bip39'
import { Transaction as CardanoTransaction, BlockchainSettings, Bip44AccountPrivate } from 'cardano-wallet'
import { InvalidMnemonic } from '../errors'
import { getBindingsForEnvironment } from '../../lib/bindings'
import { TransactionInput } from '../../Transaction'
import { AddressType } from '../../Wallet'
const { AccountIndex, AddressKeyIndex, Bip44RootPrivateKey, Entropy, TransactionFinalized, Witness } = getBindingsForEnvironment()

const HARD_DERIVATION_START = 0x80000000

const MemoryKey = {
  generateMnemonic,
  create: createMemoryKey,
  signTransaction,
  signMessage
}

function createMemoryKey (mnemonic: string, password: string, accountNumber = 0) {
  const validMnemonic = validateMnemonic(mnemonic)
  if (!validMnemonic) throw new InvalidMnemonic()

  const entropy = Entropy.from_english_mnemonics(mnemonic)
  const privateKey = Bip44RootPrivateKey.recover(entropy, password)
  return privateKey.bip44_account(AccountIndex.new(accountNumber | HARD_DERIVATION_START))
}

// Once a Cardano Transaction is "made", the TransactionInputs end up without the addressing info. It is needed here to determine
// which key index to sign with for each witness. Consider if we can make this nicer.
function signTransaction (key: Bip44AccountPrivate, transaction: CardanoTransaction, rawInputs: TransactionInput[], chainSettings: BlockchainSettings) {
  const transactionId = transaction.id()
  const transactionFinalizer = new TransactionFinalized(transaction)

  rawInputs.forEach(({ addressing }) => {
    // Not sure if we want new_extended_key or new_redeem_key. The types suggest "new_extended_key"
    const privateKey = key.address_key(addressing.change === 1, AddressKeyIndex.new(addressing.index))
    const witness = Witness.new_extended_key(chainSettings, privateKey, transactionId)
    transactionFinalizer.add_witness(witness)
  })

  return transactionFinalizer.finalize().to_hex()
}

function signMessage (key: Bip44AccountPrivate, addressType: AddressType, signingIndex: number, message: string): string {
  const privateKey = key.address_key(addressType === AddressType.internal, AddressKeyIndex.new(signingIndex))
  return privateKey.sign(Buffer.from(message)).to_hex()
}

export default MemoryKey
