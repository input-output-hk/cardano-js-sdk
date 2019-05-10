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

    const outputs = [{ address: 'Ae2tdPwUPEZEjJcLmvgKnuwUnfKSVuGCzRW1PqsLcWqmoGJUocBGbvWjjTx', value: '1000000' }]

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

    seedUtxoSet([
      { address: internalTx.inputs[0].value.address, hash: internalTx.inputs[0].pointer.id, value: '1000' },
      { address: externalTx.inputs[0].value.address, hash: internalTx.inputs[0].pointer.id, value: '2000' }
    ])

    const balance = await Wallet(mockProvider)(account).balance()
    expect(balance).to.eql(3000)
  })

  it('transaction', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetInternalAddressIndex = 5
    const targetExternalAddressIndex = 5

    const outputs = [{ address: 'Ae2tdPwUPEZEjJcLmvgKnuwUnfKSVuGCzRW1PqsLcWqmoGJUocBGbvWjjTx', value: '1000000' }]

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

    const transactions = await Wallet(mockProvider)(account).transactions()
    expect(transactions.length).to.eql(2)
  })

  it('selectInputsForTransaction', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetInternalAddressIndex = 5
    const targetExternalAddressIndex = 5

    const outputs = [{ address: 'Ae2tdPwUPEZEjJcLmvgKnuwUnfKSVuGCzRW1PqsLcWqmoGJUocBGbvWjjTx', value: '1000000' }]

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

    seedUtxoSet([
      { address: internalTx.inputs[0].value.address, hash: internalTx.inputs[0].pointer.id, value: '400000' },
      { address: externalTx.inputs[0].value.address, hash: internalTx.inputs[0].pointer.id, value: '500000' }
    ])

    const { inputs, changeOutput } = await Wallet(mockProvider)(account).selectInputsForTransaction(outputs, '1000')
    expect(inputs.length).to.eql(2)
    expect(!!changeOutput).to.eql(true)
  })
})
