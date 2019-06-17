import { expect } from 'chai'
import { AddressType, Utxo } from '.'
import { mockProvider, seedTransactionSet, seedUtxoSet, generateTestTransaction, generateTestUtxos } from '../test/utils'
import { Wallet } from './Wallet'
import { addressDiscoveryWithinBounds, generateMnemonic } from '../Utils'
import { InMemoryKeyManager, RustCardano } from '../lib'
import { ChainSettings } from '../Cardano'

describe('Wallet', () => {
  let account: string
  let wallet: ReturnType<ReturnType<typeof Wallet>>

  describe('getNextChangeAddress', () => {
    beforeEach(async () => {
      const mnemonic = generateMnemonic()
      account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()

      seedTransactionSet([])

      wallet = Wallet(RustCardano, mockProvider)(account)
    })

    it('returns the next change address for a new BIP44 account', async () => {
      const firstInternalAddress = addressDiscoveryWithinBounds(RustCardano, {
        account,
        type: AddressType.internal,
        lowerBound: 0,
        upperBound: 0
      }, ChainSettings.mainnet)[0].address

      const nextReceivingAddress = await wallet.getNextChangeAddress()
      expect(nextReceivingAddress.address).to.eql(firstInternalAddress)
      expect(nextReceivingAddress.index).to.eql(0)
      expect(nextReceivingAddress.type).to.eql(AddressType.internal)
    })
  })

  describe('getNextReceivingAddress', async () => {
    beforeEach(async () => {
      const mnemonic = generateMnemonic()
      account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()

      seedTransactionSet([])

      wallet = Wallet(RustCardano, mockProvider)(account)
    })

    it('returns the next receiving address for a new BIP44 account', async () => {
      const firstExternalAddress = addressDiscoveryWithinBounds(RustCardano, {
        account,
        type: AddressType.external,
        lowerBound: 0,
        upperBound: 0
      }, ChainSettings.mainnet)[0].address

      const nextReceivingAddress = await wallet.getNextReceivingAddress()
      expect(nextReceivingAddress.address).to.eql(firstExternalAddress)
      expect(nextReceivingAddress.index).to.eql(0)
      expect(nextReceivingAddress.type).to.eql(AddressType.external)
    })
  })

  describe('balance', async () => {
    beforeEach(async () => {
      const mnemonic = generateMnemonic()
      account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
      const targetInternalAddressIndex = 5
      const targetExternalAddressIndex = 5

      const internalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetInternalAddressIndex, account, type: AddressType.internal, value: '1000000' })
      const externalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetExternalAddressIndex, account, type: AddressType.external, value: '1000000' })

      const internalTx = generateTestTransaction({
        account,
        lowerBoundOfAddresses: 0,
        testInputs: [...Array(targetInternalAddressIndex)].map(() => ({ value: '10000000', type: AddressType.internal })),
        testOutputs: internalOutputs
      })

      const externalTx = generateTestTransaction({
        account,
        lowerBoundOfAddresses: 0,
        testInputs: [...Array(targetExternalAddressIndex)].map(() => ({ value: '10000000', type: AddressType.external })),
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

      wallet = Wallet(RustCardano, mockProvider)(account)
    })

    it('determines the balance for a BIP44 account with UTXOs', async () => {
      const balance = await wallet.balance()
      expect(balance).to.eql(3000)
    })
  })

  describe('transaction', () => {
    beforeEach(async () => {
      const mnemonic = generateMnemonic()
      account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
      const targetInternalAddressIndex = 5
      const targetExternalAddressIndex = 5

      const internalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetInternalAddressIndex, account, type: AddressType.internal, value: '1000000' })
      const externalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetExternalAddressIndex, account, type: AddressType.external, value: '1000000' })

      const internalTx = generateTestTransaction({
        account,
        lowerBoundOfAddresses: 0,
        testInputs: [...Array(targetInternalAddressIndex)].map(() => ({ value: '10000000', type: AddressType.internal })),
        testOutputs: internalOutputs
      })

      const externalTx = generateTestTransaction({
        account,
        lowerBoundOfAddresses: 0,
        testInputs: [...Array(targetExternalAddressIndex)].map(() => ({ value: '10000000', type: AddressType.external })),
        testOutputs: externalOutputs
      })

      seedTransactionSet([
        { inputs: internalTx.inputs, outputs: internalOutputs },
        { inputs: externalTx.inputs, outputs: externalOutputs }
      ])

      wallet = Wallet(RustCardano, mockProvider)(account)
    })

    it('returns a list of transactions for a BIP44 account with associated transactions', async () => {
      const transactions = await wallet.transactions()
      expect(transactions.length).to.eql(2)
    })
  })

  describe('selectInputsForTransaction', async () => {
    let internalOutputs: Utxo[]

    beforeEach(async () => {
      const mnemonic = generateMnemonic()
      account = await InMemoryKeyManager(RustCardano, { password: '', mnemonic }).publicParentKey()
      const targetInternalAddressIndex = 5
      const targetExternalAddressIndex = 5

      internalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetInternalAddressIndex, account, type: AddressType.internal, value: '1000000' })
      const externalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetExternalAddressIndex, account, type: AddressType.external, value: '1000000' })

      const internalTx = generateTestTransaction({
        account,
        lowerBoundOfAddresses: 0,
        testInputs: [...Array(targetInternalAddressIndex)].map(() => ({ value: '10000000', type: AddressType.internal })),
        testOutputs: internalOutputs
      })

      const externalTx = generateTestTransaction({
        account,
        lowerBoundOfAddresses: 0,
        testInputs: [...Array(targetExternalAddressIndex)].map(() => ({ value: '10000000', type: AddressType.external })),
        testOutputs: externalOutputs
      })

      seedTransactionSet([
        { inputs: internalTx.inputs, outputs: internalOutputs },
        { inputs: externalTx.inputs, outputs: externalOutputs }
      ])

      seedUtxoSet([
        { address: internalOutputs[0].address, id: internalTx.inputs[0].pointer.id, index: internalTx.inputs[0].pointer.index, value: '400000' },
        { address: externalOutputs[0].address, id: internalTx.inputs[1].pointer.id, index: internalTx.inputs[0].pointer.index, value: '500000' }
      ])

      wallet = Wallet(RustCardano, mockProvider)(account)
    })

    it('selects inputs from the UTXO set available for the BIP44 account', async () => {
      const testOutput = [{ address: internalOutputs[4].address, value: '1000' }]

      const { inputs, changeOutput } = await wallet.selectInputsForTransaction(testOutput)
      expect(inputs.length).to.eql(1)
      expect(!!changeOutput).to.eql(true)
    })
  })
})
