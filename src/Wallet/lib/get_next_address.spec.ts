import { expect } from 'chai'
import { mockProvider, seedTransactionSet } from '../../test/utils/mock_provider'
import { getNextAddressByType } from './get_next_address'
import { Utils } from '../..'
import { InMemoryKeyManager } from '../../KeyManager'
import { addressDiscoveryWithinBounds } from '.'
import { generateTestTransaction } from '../../test/utils/test_transaction'
import { SCAN_GAP } from '../config'
import { AddressType } from '..'

describe('getNextAddressByType', () => {
  it('returns the first address index if no transactions exist for internal addresses', async () => {
    seedTransactionSet([])

    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const firstInternalAddress = addressDiscoveryWithinBounds({
      account,
      type: AddressType.internal,
      lowerBound: 0,
      upperBound: 0
    })[0].address

    const nextChangeAddress = await getNextAddressByType(mockProvider, account, AddressType.internal)
    expect(nextChangeAddress.address).to.eql(firstInternalAddress)
    expect(nextChangeAddress.index).to.eql(0)
    expect(nextChangeAddress.type).to.eql(AddressType.internal)
  })

  it('returns the first address with no transactions for internal addresses, when the address lives within the first SCAN_GAP', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetAddressIndex = SCAN_GAP - 5

    const outputs = [...Array(targetAddressIndex)].map((_, index) => {
      const address = addressDiscoveryWithinBounds({
        account,
        type: AddressType.internal,
        lowerBound: index,
        upperBound: index
      })[0].address

      return { value: '1000000', address }
    })

    const { inputs } = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ value: '1000000000', type: AddressType.internal }],
      testOutputs: outputs
    })

    seedTransactionSet([{ inputs, outputs }])

    const nextChangeAddress = await getNextAddressByType(mockProvider, account, AddressType.internal)
    expect(nextChangeAddress.index).to.eql(targetAddressIndex)
    expect(nextChangeAddress.type).to.eql(AddressType.internal)
  })

  it('returns the first address with no transactions for internal addresses, when the address lives within beyond the first SCAN_GAP', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetAddressIndex = (SCAN_GAP * 3) - 5

    const outputs = [...Array(targetAddressIndex)].map((_, index) => {
      const address = addressDiscoveryWithinBounds({
        account,
        type: AddressType.internal,
        lowerBound: index,
        upperBound: index
      })[0].address

      return { value: '1000000', address }
    })

    const { inputs } = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ value: '1000000000', type: AddressType.internal }],
      testOutputs: outputs
    })

    seedTransactionSet([{ inputs, outputs }])

    const nextChangeAddress = await getNextAddressByType(mockProvider, account, AddressType.internal)
    expect(nextChangeAddress.index).to.eql(targetAddressIndex)
    expect(nextChangeAddress.type).to.eql(AddressType.internal)
  })

  it('returns the first address index if no transactions exist for external addresses', async () => {
    seedTransactionSet([])

    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const firstInternalAddress = addressDiscoveryWithinBounds({
      account,
      type: AddressType.external,
      lowerBound: 0,
      upperBound: 0
    })[0].address

    const nextChangeAddress = await getNextAddressByType(mockProvider, account, AddressType.external)
    expect(nextChangeAddress.address).to.eql(firstInternalAddress)
    expect(nextChangeAddress.index).to.eql(0)
    expect(nextChangeAddress.type).to.eql(AddressType.external)
  })

  it('returns the first address with no transactions for external addresses, when the address lives within the first SCAN_GAP', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetAddressIndex = SCAN_GAP - 10

    const outputs = [...Array(targetAddressIndex)].map((_, index) => {
      const address = addressDiscoveryWithinBounds({
        account,
        type: AddressType.external,
        lowerBound: index,
        upperBound: index
      })[0].address

      return { value: '1000000', address }
    })

    const { inputs } = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ value: '1000000000', type: AddressType.internal }],
      testOutputs: outputs
    })

    seedTransactionSet([{ inputs, outputs }])

    const nextChangeAddress = await getNextAddressByType(mockProvider, account, AddressType.external)
    expect(nextChangeAddress.index).to.eql(targetAddressIndex)
    expect(nextChangeAddress.type).to.eql(AddressType.external)
  })

  it('returns the first address with no transactions for external addresses, when the address lives within beyond the first SCAN_GAP', async () => {
    const mnemonic = Utils.generateMnemonic()
    const account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
    const targetAddressIndex = (SCAN_GAP * 5) - 5

    const outputs = [...Array(targetAddressIndex)].map((_, index) => {
      const address = addressDiscoveryWithinBounds({
        account,
        type: AddressType.external,
        lowerBound: index,
        upperBound: index
      })[0].address

      return { value: '1000000', address }
    })

    const { inputs } = generateTestTransaction({
      publicAccount: account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ value: '1000000000', type: AddressType.internal }],
      testOutputs: outputs
    })

    seedTransactionSet([{ inputs, outputs }])

    const nextChangeAddress = await getNextAddressByType(mockProvider, account, AddressType.external)
    expect(nextChangeAddress.index).to.eql(targetAddressIndex)
    expect(nextChangeAddress.type).to.eql(AddressType.external)
  })
})
