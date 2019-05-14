import { expect } from 'chai'
import { Utils, InMemoryKeyManager, connect } from '..'
import { generateTestTransaction } from './utils'
import { mockProvider } from './utils/mock_provider'
import { AddressType } from '../Wallet'

describe('Example: In Memory Key Manager', () => {
  const password = 'secure'

  it('allows a user to create a key manager in memory from a valid mnemonic, sign a transaction and submit it to the network', async () => {
    const mnemonic = Utils.generateMnemonic()
    const keyManager = InMemoryKeyManager({ mnemonic, password })

    const { transaction, inputs } = generateTestTransaction({
      publicAccount: keyManager.publicAccount(),
      lowerBoundOfAddresses: 0,
      testInputs: [{ type: AddressType.external, value: '1000000' }, { type: AddressType.external, value: '5000000' }],
      testOutputs: [{ address: 'Ae2tdPwUPEZEjJcLmvgKnuwUnfKSVuGCzRW1PqsLcWqmoGJUocBGbvWjjTx', value: '6000000' }]
    })

    const signedTransaction = keyManager.signTransaction(transaction, inputs)

    const transactionSubmission = await connect(mockProvider).submitTransaction(signedTransaction)
    expect(transactionSubmission).to.eql(true)
  })
})
