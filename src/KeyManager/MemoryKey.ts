import { generateMnemonic, validateMnemonic } from 'bip39'
import { Transaction as CardanoTransaction, BlockchainSettings, Bip44AccountPrivate } from 'cardano-wallet'
import { InvalidMnemonic } from './errors'
import { getBindingsForEnvironment } from '../lib/bindings'
import { TransactionInput } from '../Transaction'
const { AccountIndex, AddressKeyIndex, Bip44RootPrivateKey, Entropy, TransactionFinalized } = getBindingsForEnvironment()
const HARD_DERIVATION_START = 0x80000000

const MemoryKey = {
  generateMnemonic,
  create: createMemoryKey,
  signTransaction,
  signMessage
}

function createMemoryKey(mnemonic: string, password: string, accountNumber = 0) {
  const validMnemonic = validateMnemonic(mnemonic)
  if (!validMnemonic) throw new InvalidMnemonic()

  const entropy = Entropy.from_english_mnemonics(mnemonic)
  const privateKey = Bip44RootPrivateKey.recover(entropy, password)
  return privateKey.bip44_account(AccountIndex.new(accountNumber | HARD_DERIVATION_START))
}

function signTransaction(key: Bip44AccountPrivate, transaction: CardanoTransaction, chainSettings: BlockchainSettings) {
  const transactionInputs: TransactionInput[] = JSON.parse(transaction.to_json().inputs)
  const transactionFinalizer = new TransactionFinalized(transaction)

  transactionInputs.forEach(({addressing}) => {
    transactionFinalizer.sign(chainSettings, key.address_key(addressing.change === 1, new AddressKeyIndex(addressing.index)))
  })
}

function signMessage(key: Bip44AccountPrivate, message: string) {

}

export default MemoryKey

