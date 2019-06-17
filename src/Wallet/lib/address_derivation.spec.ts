import { expect } from 'chai'
import { InMemoryKeyManager } from '../../KeyManager'
import { generateMnemonic } from '../../Utils'
import { SCAN_GAP } from '../config'
import { generateTestTransaction, mockProvider, seedTransactionSet, generateTestUtxos } from '../../test/utils'
import { deriveAddressSet } from '.'
import { AddressType } from '..'
import { RustCardano } from '../../lib/RustCardanoPrimitives'

describe('deriveAddressSet', () => {
  it('combines external and internal addresses up to the end of each range', async () => {
    const mnemonic = generateMnemonic()
    const account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
    const targetInternalAddressIndex = SCAN_GAP - 5
    const targetExternalAddressIndex = (SCAN_GAP * 2) + 3
    const targetTotalAddresses = targetExternalAddressIndex + targetInternalAddressIndex + (SCAN_GAP * 2)

    const internalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetInternalAddressIndex, account, type: AddressType.internal, value: '1000000' })
    const internalTx = generateTestTransaction({
      account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ type: AddressType.external, value: '6000000000' }],
      testOutputs: internalOutputs
    })

    const externalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetExternalAddressIndex, account, type: AddressType.external, value: '1000000' })
    const externalTx = generateTestTransaction({
      account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ type: AddressType.external, value: '6000000000' }],
      testOutputs: externalOutputs
    })

    seedTransactionSet([
      { inputs: internalTx.inputs, outputs: externalOutputs },
      { inputs: externalTx.inputs, outputs: internalOutputs }
    ])

    const derivedAddressSet = await deriveAddressSet(RustCardano, mockProvider, account)
    expect(derivedAddressSet.length).to.eql(targetTotalAddresses)
  })
})
