import { expect } from 'chai'
import KeyManager from '.'
import { KeyAccess } from '../KeyAccess'
import MemoryKey from '../MemoryKey'
import { AddressType } from '../../Wallet'
import { generateTestTransaction } from '../../utils/test/test_transaction'
import { InvalidKeyType } from '../errors'

describe('KeyManager', () => {
  describe('MemoryKey', () => {
    it('exposes the correct interface', () => {
      const mnemonic = MemoryKey.generateMnemonic()
      const keypair = MemoryKey.create(mnemonic, 'securepassword')
      const keys = KeyManager(KeyAccess.memory, keypair)
      const { transaction, inputs } = generateTestTransaction(keypair.public())
      expect(typeof keys.signMessage(AddressType.external, 0, 'hello world')).to.equal('string')
      expect(typeof keys.signTransaction(transaction, inputs)).to.equal('string')
    })
  })

  it('throws if the key access type is not recognise', () => {
    const mnemonic = MemoryKey.generateMnemonic()
    const keypair = MemoryKey.create(mnemonic, 'securepassword')
    expect(() => KeyManager('fake' as KeyAccess, keypair)).to.throw(InvalidKeyType)
  })
})
