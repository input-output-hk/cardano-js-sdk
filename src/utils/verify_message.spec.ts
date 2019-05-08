import { expect } from 'chai'
import { InMemoryKeyManager } from '../KeyManager'
import { AddressType } from '../Wallet'
import { verifyMessage } from './verify_message'

describe('utils', () => {
  describe('verifyMessage', () => {
    it('returns true when verifying a correct signature for a message', () => {
      const message = 'foobar'
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keyManager = InMemoryKeyManager({ mnemonic, password: 'securepassword' })
      const { signature, publicKey } = keyManager.signMessage(AddressType.external, 0, message)

      const verification = verifyMessage({
        publicKey,
        message,
        signature
      })

      expect(verification).to.eql(true)
    })

    it('returns false when verifying an incorrect message for a valid signature', () => {
      const message = 'foobar'
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keyManager = InMemoryKeyManager({ mnemonic, password: 'securepassword' })
      const { signature, publicKey } = keyManager.signMessage(AddressType.external, 0, message)

      const verification = verifyMessage({
        publicKey,
        message: 'a differnt message',
        signature
      })

      expect(verification).to.eql(false)
    })
  })
})
