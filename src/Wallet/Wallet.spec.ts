import { expect } from 'chai'
import { MemoryKeyManager } from '../KeyManager'
import Wallet, { AddressType } from '.'

describe('Wallet', () => {
  describe('verifyMessage', () => {
    it('returns true when verifying a correct signature for a message', () => {
      const message = 'foobar'
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keyManager = MemoryKeyManager({ mnemonic, password: 'securepassword' })
      const signatureAsHex = keyManager.signMessage(AddressType.external, 0, message)

      const verification = Wallet(keyManager.publicAccount()).verifyMessage({
        addressType: AddressType.external,
        message,
        signingIndex: 0,
        signatureAsHex
      })

      expect(verification).to.eql(true)
    })

    it('returns false when verifying an incorrect message for a valid signature', () => {
      const message = 'foobar'
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keyManager = MemoryKeyManager({ mnemonic, password: 'securepassword' })
      const signatureAsHex = keyManager.signMessage(AddressType.external, 0, message)

      const verification = Wallet(keyManager.publicAccount()).verifyMessage({
        addressType: AddressType.external,
        message: 'a different message',
        signingIndex: 0,
        signatureAsHex
      })

      expect(verification).to.eql(false)
    })
  })
})
