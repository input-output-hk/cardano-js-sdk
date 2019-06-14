import { expect } from 'chai'
import { InMemoryKeyManager } from '../../KeyManager'
import { AddressType } from '../../Wallet'
import { RustCardano } from './RustCardano'
import { hexGenerator } from '../../test/utils'
import { generateMnemonic, addressDiscoveryWithinBounds } from '../../Utils'

describe('RustCardano', () => {
  describe('verifyMessage', () => {
    it('returns true when verifying a correct signature for a message', async () => {
      const message = 'foobar'
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keyManager = InMemoryKeyManager(RustCardano, { mnemonic, password: 'securepassword' })
      const { signature, publicKey } = await keyManager.signMessage(AddressType.external, 0, message)

      const verification = RustCardano.verifyMessage({
        publicKey,
        message,
        signature
      })

      expect(verification).to.eql(true)
    })

    it('returns false when verifying an incorrect message for a valid signature', async () => {
      const message = 'foobar'
      const mnemonic = 'height bubble drama century ask online stage camp point loyal hip awesome'
      const keyManager = InMemoryKeyManager(RustCardano, { mnemonic, password: 'securepassword' })
      const { signature, publicKey } = await keyManager.signMessage(AddressType.external, 0, message)

      const verification = RustCardano.verifyMessage({
        publicKey,
        message: 'a differnt message',
        signature
      })

      expect(verification).to.eql(false)
    })
  })
  describe('inputSelection', () => {
    it('throws if there is insufficient inputs to cover the payment cost', async () => {
      const mnemonic = generateMnemonic()
      const account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
      const [address1, address2, address3, changeAddress] = addressDiscoveryWithinBounds(RustCardano, {
        account,
        type: AddressType.internal,
        lowerBound: 0,
        upperBound: 5
      })

      const utxosWithAddressing = [
        { address: address1.address, value: '1000', id: hexGenerator(64), index: 0, addressing: { index: 0, change: 0, accountIndex: 0 } },
        { address: address2.address, value: '1000', id: hexGenerator(64), index: 1, addressing: { index: 0, change: 0, accountIndex: 0 } }
      ]

      const outputs = [
        { address: address3.address, value: '1000000' }
      ]

      expect(() => RustCardano.inputSelection(outputs, utxosWithAddressing, changeAddress.address)).to.throw('NotEnoughInput')
    })

    describe('FirstMatchFirst', () => {
      it('selects valid UTXOs and produces change', async () => {
        const mnemonic = generateMnemonic()
        const account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
        const [address1, address2, address3, address4, address5, change] = addressDiscoveryWithinBounds(RustCardano, {
          account,
          type: AddressType.internal,
          lowerBound: 0,
          upperBound: 5
        })

        // Any combination of these inputs will always produce change
        const utxosWithAddressing = [
          { address: address1.address, value: '600000', id: hexGenerator(64), index: 0, addressing: { index: 0, change: 0, accountIndex: 0 } },
          { address: address2.address, value: '500000', id: hexGenerator(64), index: 1, addressing: { index: 0, change: 0, accountIndex: 0 } },
          { address: address3.address, value: '330000', id: hexGenerator(64), index: 2, addressing: { index: 0, change: 0, accountIndex: 0 } },
          { address: address4.address, value: '410000', id: hexGenerator(64), index: 3, addressing: { index: 0, change: 0, accountIndex: 0 } }
        ]

        const outputs = [
          { address: address5.address, value: '10000' }
        ]

        const { inputs, changeOutput } = RustCardano.inputSelection(outputs, utxosWithAddressing, change.address)
        expect(inputs.length > 0).to.eql(true)
        expect(changeOutput.address).to.eql(change.address)
      })
    })
  })
})
