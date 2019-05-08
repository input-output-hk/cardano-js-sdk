import { expect } from 'chai'
import { InMemoryKeyManager } from '.'
import { InvalidMnemonic } from '../errors'
import { AddressType } from '../../Wallet'
import { getBindingsForEnvironment } from '../../lib/bindings'
import { generateTestTransaction } from '../../test/utils/test_transaction'
import { generateMnemonic } from '../../Utils'
const { BlockchainSettings } = getBindingsForEnvironment()

describe('MemoryKeyManager', () => {
  it('throws if the mnemonic passed is invalid', () => {
    const invalidMnemonic = 'xxxx'
    expect(() => InMemoryKeyManager({ mnemonic: invalidMnemonic, password: 'xx' })).to.throw(InvalidMnemonic)
  })

  describe('publicAccount', () => {
    it('exposes a Bip44 public account', () => {
      const mnemonic = generateMnemonic()
      const keyManager = InMemoryKeyManager({ mnemonic, password: 'securepassword' })
      expect(keyManager.publicAccount).to.be.an.instanceOf(Function)
    })
  })

  describe('signTransaction', () => {
    it('adds witnesses to a transaction and returns the hex of the signed transaction', () => {
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keyManager = InMemoryKeyManager({ mnemonic, password: 'securepassword' })
      const { transaction, inputs } = generateTestTransaction(keyManager.publicAccount())
      const signedTransaction = keyManager.signTransaction(transaction, inputs, BlockchainSettings.mainnet())
      expect(signedTransaction.length).to.eql(838)
    })
  })

  describe('signMessage', () => {
    it('returns a signed message for a private key index', () => {
      const message = 'foobar'
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keyManager = InMemoryKeyManager({ mnemonic, password: 'securepassword' })
      const { signature } = keyManager.signMessage(AddressType.external, 0, message)
      const expectedSignature = '175121c7d4c18007e0f693181584c74a3b0d667cfbe2b81f5e2afba74dc1070b818f500d26a74e9b23a9a8b0246356a156b33bb17de979f3b429c4b1cfff2303'
      expect(signature).to.eql(expectedSignature)
    })
  })
})
