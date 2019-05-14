import { expect } from 'chai'
import { Utils, InMemoryKeyManager } from '..'
import { AddressType, addressDiscoveryWithinBounds, Utxo } from '.'
import { mockProvider, seedTransactionSet, seedUtxoSet, generateTestTransaction, generateTestUtxos } from '../test/utils'
import { Wallet } from './Wallet'
import { Bip44AccountPublic } from 'cardano-wallet'

describe('Wallet', () => {
  describe('getNextChangeAddress', () => {
    let account: Bip44AccountPublic

    beforeEach(() => {
      const mnemonic = Utils.generateMnemonic()
      account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()

      seedTransactionSet([])
    })

    it('returns the next change address for a new BIP44 public account', async () => {
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
  })

  describe('getNextReceivingAddress', async () => {
    let account: Bip44AccountPublic

    beforeEach(() => {
      const mnemonic = Utils.generateMnemonic()
      account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()

      seedTransactionSet([])
    })

    it('returns the next receiving address for a new BIP44 public account', async () => {
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
  })

  describe('balance', async () => {
    let account: Bip44AccountPublic

    beforeEach(() => {
      const mnemonic = Utils.generateMnemonic()
      account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
      const targetInternalAddressIndex = 5
      const targetExternalAddressIndex = 5

      const internalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetInternalAddressIndex, account, type: AddressType.internal, value: '1000000' })
      const externalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetExternalAddressIndex, account, type: AddressType.external, value: '1000000' })

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
    })

    it('determines the balance for a BIP44 public account with utxos', async () => {
      const balance = await Wallet(mockProvider)(account).balance()
      expect(balance).to.eql(3000)
    })
  })

  describe('transaction', () => {
    let account: Bip44AccountPublic

    beforeEach(() => {
      const mnemonic = Utils.generateMnemonic()
      account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
      const targetInternalAddressIndex = 5
      const targetExternalAddressIndex = 5

      const internalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetInternalAddressIndex, account, type: AddressType.internal, value: '1000000' })
      const externalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetExternalAddressIndex, account, type: AddressType.external, value: '1000000' })

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
    })

    it('returns a list of transactions for a BIP44 public account with associated transactions', async () => {
      const transactions = await Wallet(mockProvider)(account).transactions()
      expect(transactions.length).to.eql(2)
    })
  })

  describe('selectInputsForTransaction', async () => {
    let account: Bip44AccountPublic
    let internalOutputs: Utxo[]

    beforeEach(() => {
      const mnemonic = Utils.generateMnemonic()
      account = InMemoryKeyManager({ password: '', mnemonic }).publicAccount()
      const targetInternalAddressIndex = 5
      const targetExternalAddressIndex = 5

      internalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetInternalAddressIndex, account, type: AddressType.internal, value: '1000000' })
      const externalOutputs = generateTestUtxos({ lowerBound: 0, upperBound: targetExternalAddressIndex, account, type: AddressType.external, value: '1000000' })

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
        { address: externalOutputs[0].address, id: internalTx.inputs[1].pointer.id, index: internalTx.inputs[0].pointer.index, value: '500000' }
      ])
    })

    it('selects inputs from the utxo set available for the BIP44 public account', async () => {
      const testOutput = [{ address: internalOutputs[4].address, value: '1000' }]

      const { inputs, changeOutput } = await Wallet(mockProvider)(account).selectInputsForTransaction(testOutput)
      expect(inputs.length).to.eql(1)
      expect(!!changeOutput).to.eql(true)
    })
  })
})
