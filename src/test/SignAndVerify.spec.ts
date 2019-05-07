import { expect } from 'chai'
import CardanoSdk from '..'
import { AddressType } from '../Wallet'

describe('Example: Sign And Verify', () => {
  it('allows a user to sign a message that can be verified by others who have a reference to the public key', () => {
    const mnemonic = CardanoSdk.Utils.generateMnemonic()
    const keyManager = CardanoSdk.MemoryKeyManager({ mnemonic, password: '' })
    const message = 'hello world'
    const { signature, publicKey } = keyManager.signMessage(AddressType.external, 0, message)

    expect(CardanoSdk.Utils.verifyMessage({
      publicKey,
      message,
      signature: signature
    })).to.eql(true)
  })
})
