import { expect } from 'chai'
import { Utils, InMemoryKeyManager, connect } from '..'
import { generateTestTransaction } from './utils/test_transaction'
import { mockProvider } from './utils/mock_provider'

describe('Example: In Memory Key Manager', () => {
  const password = 'secure'

  it('allows a user to create a key manager in memory from a valid mnemonic, sign a transaction and submit it to the network', async () => {
    const mnemonic = Utils.generateMnemonic()
    const keyManager = InMemoryKeyManager({ mnemonic, password })
    const { transaction, inputs } = generateTestTransaction(keyManager.publicAccount())
    const signedTransaction = keyManager.signTransaction(transaction, inputs)

    const transactionSubmission = await connect(mockProvider).submitTransaction(signedTransaction)
    expect(transactionSubmission).to.eql(true)
  })
})
