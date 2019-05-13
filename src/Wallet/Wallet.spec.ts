import { expect } from 'chai'
import { Utils, InMemoryKeyManager } from '..'
import { AddressType, addressDiscoveryWithinBounds } from '.'
import { mockProvider, seedTransactionSet, seedUtxoSet } from '../test/utils/mock_provider'
import { Wallet } from './Wallet'
import { generateTestTransaction } from '../test/utils/test_transaction'

describe('Wallet', () => {
  it('getNextChangeAddress', async () => {
    seedTransactionSet([])

    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const firstInternalAddress = addressDiscoveryWithinBounds({
      account,
      type: AddressType.internal,
      lowerBound: 0,
      upperBound: 0
    })[0].address

    const nextReceivingAddress = await Wallet(mockProvider)(account).getNextChangeAddress()
    expect(nextReceivingAddress.address).to.eql(firstInternalAddress)
    expect(nextReceivingAddress.index).to.eql(0)
    expect(nextReceivingAddress.type).to.eql(AddressType.internal)
  })

  it('getNextReceivingAddress', async () => {
    seedTransactionSet([])

    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const firstExternalAddress = addressDiscoveryWithinBounds({
      account,
      type: AddressType.external,
      lowerBound: 0,
      upperBound: 0
    })[0].address

    const nextReceivingAddress = await Wallet(mockProvider)(account).getNextReceivingAddress()
    expect(nextReceivingAddress.address).to.eql(firstExternalAddress)
    expect(nextReceivingAddress.index).to.eql(0)
    expect(nextReceivingAddress.type).to.eql(AddressType.external)
  })

  it('balance', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetInternalAddressIndex = 5
    const targetExternalAddressIndex = 5

    const internalOutputs = [...Array(targetInternalAddressIndex)].map((_, index) => {
      const address = addressDiscoveryWithinBounds({
        account,
        type: AddressType.internal,
        lowerBound: index,
        upperBound: index
      })[0].address

      return { value: '1000000', address }
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

    const internalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [...Array(targetInternalAddressIndex)].map(() => ({ value: '1000000', type: AddressType.internal })),
      testOutputs: internalOutputs
    })

    const externalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [...Array(targetExternalAddressIndex)].map(() => ({ value: '1000000', type: AddressType.external })),
      testOutputs: externalOutputs
    })

    seedTransactionSet([
      { inputs: internalTx.inputs, outputs: internalOutputs },
      { inputs: externalTx.inputs, outputs: externalOutputs }
    ])

    seedUtxoSet([
      { address: internalOutputs[0].address, id: internalTx.inputs[0].pointer.id, index: internalTx.inputs[0].pointer.index, value: '1000' },
      { address: externalOutputs[0].address, id: internalTx.inputs[0].pointer.id, index: internalTx.inputs[0].pointer.index, value: '2000' }
    ])

    const balance = await Wallet(mockProvider)(account).balance()
    expect(balance).to.eql(3000)
  })

  it('transaction', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetInternalAddressIndex = 5
    const targetExternalAddressIndex = 5

    const internalOutputs = [...Array(targetInternalAddressIndex)].map((_, index) => {
      const address = addressDiscoveryWithinBounds({
        account,
        type: AddressType.internal,
        lowerBound: index,
        upperBound: index
      })[0].address

      return { value: '1000000', address }
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

    const internalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [...Array(targetInternalAddressIndex)].map(() => ({ value: '1000000', type: AddressType.internal })),
      testOutputs: internalOutputs
    })

    const externalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [...Array(targetExternalAddressIndex)].map(() => ({ value: '1000000', type: AddressType.external })),
      testOutputs: externalOutputs
    })

    seedTransactionSet([
      { inputs: internalTx.inputs, outputs: internalOutputs },
      { inputs: externalTx.inputs, outputs: externalOutputs }
    ])

    const transactions = await Wallet(mockProvider)(account).transactions()
    expect(transactions.length).to.eql(2)
  })

  it('selectInputsForTransaction', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetInternalAddressIndex = 5
    const targetExternalAddressIndex = 5

    const internalOutputs = [...Array(targetInternalAddressIndex)].map((_, index) => {
      const address = addressDiscoveryWithinBounds({
        account,
        type: AddressType.internal,
        lowerBound: index,
        upperBound: index
      })[0].address

      return { value: '1000000', address }
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

    const internalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [...Array(targetInternalAddressIndex)].map(() => ({ value: '1000000', type: AddressType.internal })),
      testOutputs: internalOutputs
    })

    const externalTx = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [...Array(targetExternalAddressIndex)].map(() => ({ value: '1000000', type: AddressType.external })),
      testOutputs: externalOutputs
    })

    seedTransactionSet([
      { inputs: internalTx.inputs, outputs: internalOutputs },
      { inputs: externalTx.inputs, outputs: externalOutputs }
    ])

    seedUtxoSet([
      { address: internalOutputs[0].address, id: internalTx.inputs[0].pointer.id, index: internalTx.inputs[0].pointer.index, value: '400000' },
      { address: externalOutputs[0].address, id: internalTx.inputs[0].pointer.id, index: internalTx.inputs[0].pointer.index, value: '500000' }
    ])

    const testOutput = [{ address: internalOutputs[4].address, value: '1000' }]

    const { inputs, changeOutput } = await Wallet(mockProvider)(account).selectInputsForTransaction(testOutput)
    expect(inputs.length).to.eql(2)
    expect(!!changeOutput).to.eql(true)
  })
})
