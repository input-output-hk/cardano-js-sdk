import { LedgerKeyManager } from '.'
import { KeyManager } from '../KeyManager'
import { generateTestTransaction, generateTestUtxos } from '../../test/utils'
import { AddressType } from '../../Wallet'
import { getBindingsForEnvironment } from '../../lib/bindings'
import { UnsupportedOperation, InsufficientData } from '../errors'
import { expect, use } from 'chai'
import * as chaiAsPromised from 'chai-as-promised'
const { AddressKeyIndex, BlockchainSettings } = getBindingsForEnvironment()
use(chaiAsPromised)

const runLedgerSpecs = process.env.LEDGER_SPECS!! ? describe.only : describe.skip

runLedgerSpecs('LedgerKeyManager', async function () {
  this.timeout(60000)
  let manager: KeyManager

  before(async () => {
    manager = await LedgerKeyManager(0)
  })

  describe('publicAccount', () => {
    it('exposes a Bip44 public account', async () => {
      const pk = await manager.publicAccount()
      const address = pk
        .bip44_chain(false)
        .address_key(AddressKeyIndex.new(0))
        .bootstrap_era_address(BlockchainSettings.mainnet())
        .to_base58()

      expect(typeof address).to.be.eql('string')
    })
  })

  describe('signMessage', () => {
    it('throws as this method is not supported', async () => {
      const unsupportedSignMessageRequest = manager.signMessage(AddressType.external, 0, 'hello world!')
      return expect(unsupportedSignMessageRequest).to.eventually.be.rejectedWith(UnsupportedOperation)
    })
  })

  describe('signTransaction', () => {
    it('throws if preceding transactions for inputs being spent are not provided', async () => {
      const account = await manager.publicAccount()
      const outputs = generateTestUtxos({ lowerBound: 0, upperBound: 5, account, type: AddressType.internal, value: '1000000' })

      const { transaction } = generateTestTransaction({
        publicAccount: account,
        lowerBoundOfAddresses: 0,
        testInputs: [{ value: '1000000000', type: AddressType.internal }],
        testOutputs: outputs
      })

      const spendingTransaction = generateTestTransaction({
        publicAccount: account,
        lowerBoundOfAddresses: 0,
        testInputs: [{ value: '1000000', type: AddressType.external }],
        testOutputs: [{ value: '900000', address: 'Ae2tdPwUPEZEjJcLmvgKnuwUnfKSVuGCzRW1PqsLcWqmoGJUocBGbvWjjTx' }],
        inputId: transaction.id().to_hex()
      })

      const insufficientDataForSigning = manager.signTransaction(spendingTransaction.transaction, spendingTransaction.inputs, BlockchainSettings.mainnet(), {})
      return expect(insufficientDataForSigning).to.eventually.be.rejectedWith(InsufficientData)
    })

    it('signs a transaction with a ledger device', async () => {
      const account = await manager.publicAccount()
      const outputs = generateTestUtxos({ lowerBound: 0, upperBound: 5, account, type: AddressType.internal, value: '1000000' })

      const { transaction } = generateTestTransaction({
        publicAccount: account,
        lowerBoundOfAddresses: 0,
        testInputs: [{ value: '1000000000', type: AddressType.internal }],
        testOutputs: outputs
      })

      const transactionsAsProofForSpending = {
        [transaction.id().to_hex()]: transaction.toHex()
      }

      const spendingTransaction = generateTestTransaction({
        publicAccount: account,
        lowerBoundOfAddresses: 0,
        testInputs: [{ value: '1000000', type: AddressType.external }],
        testOutputs: [{ value: '900000', address: 'Ae2tdPwUPEZEjJcLmvgKnuwUnfKSVuGCzRW1PqsLcWqmoGJUocBGbvWjjTx' }],
        inputId: transaction.id().to_hex()
      })

      await manager.signTransaction(spendingTransaction.transaction, spendingTransaction.inputs, BlockchainSettings.mainnet(), transactionsAsProofForSpending)
    })
  })
})
