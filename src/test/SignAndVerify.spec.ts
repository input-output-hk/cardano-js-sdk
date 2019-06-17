import { expect } from 'chai'
import CardanoSDK from '..'
import { AddressType } from '../Wallet'

describe('Example: Sign And Verify', () => {
  let cardano: ReturnType<typeof CardanoSDK>
  beforeEach(() => {
    cardano = CardanoSDK()
  })

  it('allows a user to sign a message that can be verified by others who have a reference to the public key', async () => {
    const mnemonic = cardano.Utils.generateMnemonic()
    const keyManager = cardano.InMemoryKeyManager({ mnemonic, password: '' })
    const message = 'hello world'
    const { signature, publicKey } = await keyManager.signMessage(AddressType.external, 0, message)

    expect(cardano.Utils.verifyMessage({
      publicKey,
      message,
      signature: signature
    })).to.eql(true)
  })
})
