import { expect } from 'chai'
import { MemoryKey } from '../../KeyManager'

import { AddressType } from '..'
import { verifyMessage } from './verify_message'

describe('verifyMessage', () => {
  it('returns true when verifying a correct signature for a message', () => {
    const message = 'foobar'
    const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
    const keypair = MemoryKey({ mnemonic, password: 'securepassword' })
    const signatureAsHex = keypair.signMessage(AddressType.external, 0, message)

    const verification = verifyMessage(keypair.publicAccount(), {
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
    const keypair = MemoryKey({ mnemonic, password: 'securepassword' })
    const signatureAsHex = keypair.signMessage(AddressType.external, 0, message)

    const verification = verifyMessage(keypair.publicAccount(), {
      addressType: AddressType.external,
      message: 'a different message',
      signingIndex: 0,
      signatureAsHex
    })

    expect(verification).to.eql(false)
  })
})
