import { expect } from 'chai'
import { Utils, InMemoryKeyManager } from '../..'
import { SCAN_GAP } from '../config'
import { generateTestTransaction } from '../../test/utils/test_transaction'
import { deriveAddressSet, addressDiscoveryWithinBounds } from '.'
import { mockProvider, seedTransactionSet } from '../../test/utils/mock_provider'
import { AddressType } from '..'

describe('deriveAddressSet', () => {
  it('combines external and internal addresses up to the end of each range', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetInternalAddressIndex = SCAN_GAP - 5
    const targetExternalAddressIndex = (SCAN_GAP * 2) + 3

    const targetTotalAddresses = targetExternalAddressIndex + targetInternalAddressIndex + (SCAN_GAP * 2)

    const internalOutputs = [...Array(targetInternalAddressIndex)].map((_, index) => {
      const address = addressDiscoveryWithinBounds({
        account,
        type: AddressType.internal,
        lowerBound: index,
        upperBound: index
      })[0].address

      return { value: '1000000', address }
    })

    const internalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ type: AddressType.external, value: '6000000000' }],
      testOutputs: internalOutputs
    })

    const externalOutputs = [...Array(targetExternalAddressIndex)].map((_, index) => {
      const address = addressDiscoveryWithinBounds({
        account,
        type: AddressType.external,
        lowerBound: index,
        upperBound: index
      })[0].address

      return { value: '1000000', address }
    })

    const externalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ type: AddressType.external, value: '6000000000' }],
      testOutputs: externalOutputs
    })

    seedTransactionSet([
      { inputs: internalTx.inputs, outputs: externalOutputs },
      { inputs: externalTx.inputs, outputs: internalOutputs }
    ])

    const derivedAddressSet = await deriveAddressSet(mockProvider, account)
    expect(derivedAddressSet.length).to.eql(targetTotalAddresses)
  })
})
