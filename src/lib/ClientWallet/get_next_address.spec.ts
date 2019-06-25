import { expect } from 'chai'
import { getNextAddressByType } from './get_next_address'
import { generateMnemonic, addressDiscoveryWithinBounds } from '../../Utils'
import { generateTestTransaction, generateTestUtxos, mockProvider, seedTransactionSet } from '../../test/utils'
import { SCAN_GAP } from '../../Wallet/config'
import { AddressType } from '../../Wallet'
import { InMemoryKeyManager, RustCardano } from '..'
import { ChainSettings } from '../../Cardano'

describe('getNextAddressByType', () => {
  it('returns the first address index if no transactions exist for internal addresses', async () => {
    seedTransactionSet([])

    const mnemonic = generateMnemonic()
    const account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
    const firstInternalAddress = addressDiscoveryWithinBounds(RustCardano, {
      account,
      type: AddressType.internal,
      lowerBound: 0,
      upperBound: 0
    }, ChainSettings.mainnet)[0].address

    const nextChangeAddress = await getNextAddressByType(RustCardano, mockProvider, account, AddressType.internal)
    expect(nextChangeAddress.address).to.eql(firstInternalAddress)
    expect(nextChangeAddress.index).to.eql(0)
    expect(nextChangeAddress.type).to.eql(AddressType.internal)
  })

  it('returns the first address with no transactions for internal addresses, when the address lives within the first SCAN_GAP', async () => {
    const mnemonic = generateMnemonic()
    const account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
    const targetAddressIndex = SCAN_GAP - 5
    const outputs = generateTestUtxos({ lowerBound: 0, upperBound: targetAddressIndex, account, type: AddressType.internal, value: '1000000' })

    const { inputs } = generateTestTransaction({
      account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ value: '1000000000', type: AddressType.internal }],
      testOutputs: outputs
    })

    seedTransactionSet([{ inputs, outputs }])

    const nextChangeAddress = await getNextAddressByType(RustCardano, mockProvider, account, AddressType.internal)
    expect(nextChangeAddress.index).to.eql(targetAddressIndex)
    expect(nextChangeAddress.type).to.eql(AddressType.internal)
  })

  it('returns the first address with no transactions for internal addresses, when the address lives within beyond the first SCAN_GAP', async () => {
    const mnemonic = generateMnemonic()
    const account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
    const targetAddressIndex = (SCAN_GAP * 3) - 5
    const outputs = generateTestUtxos({ lowerBound: 0, upperBound: targetAddressIndex, account, type: AddressType.internal, value: '1000000' })

    const { inputs } = generateTestTransaction({
      account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ value: '1000000000', type: AddressType.internal }],
      testOutputs: outputs
    })

    seedTransactionSet([{ inputs, outputs }])

    const nextChangeAddress = await getNextAddressByType(RustCardano, mockProvider, account, AddressType.internal)
    expect(nextChangeAddress.index).to.eql(targetAddressIndex)
    expect(nextChangeAddress.type).to.eql(AddressType.internal)
  })

  it('returns the first address index if no transactions exist for external addresses', async () => {
    seedTransactionSet([])

    const mnemonic = generateMnemonic()
    const account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
    const firstInternalAddress = addressDiscoveryWithinBounds(RustCardano, {
      account,
      type: AddressType.external,
      lowerBound: 0,
      upperBound: 0
    }, ChainSettings.mainnet)[0].address

    const nextChangeAddress = await getNextAddressByType(RustCardano, mockProvider, account, AddressType.external)
    expect(nextChangeAddress.address).to.eql(firstInternalAddress)
    expect(nextChangeAddress.index).to.eql(0)
    expect(nextChangeAddress.type).to.eql(AddressType.external)
  })

  it('returns the first address with no transactions for external addresses, when the address lives within the first SCAN_GAP', async () => {
    const mnemonic = generateMnemonic()
    const account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
    const targetAddressIndex = SCAN_GAP - 10
    const outputs = generateTestUtxos({ lowerBound: 0, upperBound: targetAddressIndex, account, type: AddressType.external, value: '1000000' })

    const { inputs } = generateTestTransaction({
      account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ value: '1000000000', type: AddressType.internal }],
      testOutputs: outputs
    })

    seedTransactionSet([{ inputs, outputs }])

    const nextChangeAddress = await getNextAddressByType(RustCardano, mockProvider, account, AddressType.external)
    expect(nextChangeAddress.index).to.eql(targetAddressIndex)
    expect(nextChangeAddress.type).to.eql(AddressType.external)
  })

  it('returns the first address with no transactions for external addresses, when the address lives within beyond the first SCAN_GAP', async () => {
    const mnemonic = generateMnemonic()
    const account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
    const targetAddressIndex = (SCAN_GAP * 5) - 5
    const outputs = generateTestUtxos({ lowerBound: 0, upperBound: targetAddressIndex, account, type: AddressType.external, value: '1000000' })

    const { inputs } = generateTestTransaction({
      account,
      lowerBoundOfAddresses: 0,
      testInputs: [{ value: '1000000000', type: AddressType.internal }],
      testOutputs: outputs
    })

    seedTransactionSet([{ inputs, outputs }])

    const nextChangeAddress = await getNextAddressByType(RustCardano, mockProvider, account, AddressType.external)
    expect(nextChangeAddress.index).to.eql(targetAddressIndex)
    expect(nextChangeAddress.type).to.eql(AddressType.external)
  })
})
