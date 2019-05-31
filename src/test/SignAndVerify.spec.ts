import { expect } from 'chai'
import { Utils, InMemoryKeyManager } from '..'
import { AddressType } from '../Wallet'

describe('Example: Sign And Verify', () => {
  it('allows a user to sign a message that can be verified by others who have a reference to the public key', async () => {
    const mnemonic = Utils.generateMnemonic()
    const keyManager = InMemoryKeyManager({ mnemonic, password: '' })
    const message = 'hello world'
    const { signature, publicKey } = await keyManager.signMessage(AddressType.external, 0, message)

    expect(Utils.verifyMessage({
      publicKey,
      message,
      signature: signature
    })).to.eql(true)
  })
})
