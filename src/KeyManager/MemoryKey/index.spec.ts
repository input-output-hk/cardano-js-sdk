import { expect } from 'chai'
import MemoryKey from '.'
import { InvalidMnemonic } from '../errors'
import { AddressType } from '../../Wallet'
import { getBindingsForEnvironment } from '../../lib/bindings'
import { generateTestTransaction } from '../../utils/test/test_transaction'
const { BlockchainSettings } = getBindingsForEnvironment()

describe('MemoryKey', () => {
  describe('createMemoryKey', () => {
    it('throws if the mnemonic passed is invalid', () => {
      const invalidMnemonic = 'xxxx'
      expect(() => MemoryKey.create(invalidMnemonic, 'xx')).to.throw(InvalidMnemonic)
    })

    it('returns a Bip44 Account Private Key', () => {
      const mnemonic = MemoryKey.generateMnemonic()
      const keypair = MemoryKey.create(mnemonic, 'securepassword')
      expect(keypair.public).to.be.an.instanceOf(Function)
      expect(keypair.address_key).to.be.an.instanceOf(Function)
    })
  })

  describe('signTransaction', () => {
    it('adds witnesses to a transaction and returns the hex of the signed transaction', () => {
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keypair = MemoryKey.create(mnemonic, 'securepassword')
      const { transaction, inputs } = generateTestTransaction(keypair.public())
      const signedTransaction = MemoryKey.signTransaction(keypair, transaction, inputs, BlockchainSettings.mainnet())
      expect(signedTransaction.length).to.eql(838)
    })
  })

  describe('signMessage', () => {
    it('returns a signed message for a private key index', () => {
      const message = 'foobar'
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keypair = MemoryKey.create(mnemonic, 'securepassword')

      const signature = MemoryKey.signMessage(keypair, AddressType.external, 0, message)
      const expectedSignature = '175121c7d4c18007e0f693181584c74a3b0d667cfbe2b81f5e2afba74dc1070b818f500d26a74e9b23a9a8b0246356a156b33bb17de979f3b429c4b1cfff2303'
      expect(signature).to.eql(expectedSignature)
    })
  })
})
