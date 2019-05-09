import { expect } from 'chai'
import { Utils, InMemoryKeyManager } from '../..'
import { SCAN_GAP } from '../config'
import { generateTestTransaction } from '../../test/utils/test_transaction'
import { AddressType, deriveAddressSet } from '.'
import { mockProvider, seedTransactionSet } from '../../test/utils/mock_provider'

describe('deriveAddressSet', () => {
  it('combines external and internal addresses up to the end of each range', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetInternalAddressIndex = SCAN_GAP - 5
    const targetExternalAddressIndex = (SCAN_GAP * 2) + 3
    const targetTotalAddresses = targetExternalAddressIndex + targetInternalAddressIndex

    const outputs = [{ address: 'Ae2tdPwUPEZEjJcLmvgKnuwUnfKSVuGCzRW1PqsLcWqmoGJUocBGbvWjjTx', value: '6000000' }]
    const internalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [...Array(targetInternalAddressIndex)].map(() => ({ value: '1000000', type: AddressType.internal })),
      testOutputs: outputs
    })

    const externalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [...Array(targetExternalAddressIndex)].map(() => ({ value: '1000000', type: AddressType.external })),
      testOutputs: outputs
    })

    seedTransactionSet([
      { inputs: internalTx.inputs, outputs },
      { inputs: externalTx.inputs, outputs }
    ])

    const derivedAddressSet = await deriveAddressSet(mockProvider, account)
    expect(derivedAddressSet.length).to.eql(targetTotalAddresses)
  })
})
