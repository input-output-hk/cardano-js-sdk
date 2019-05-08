import { expect } from 'chai'
import { Utils, InMemoryKeyManager, connect } from '..'
import { generateTestTransaction } from './utils/test_transaction'
import { mockProvider } from './utils/mock_provider'

describe('Example: Memory Key Manager', () => {
  const password = 'secure'

  it('allows a user to create a new memory key from a valid mnemonic, sign a transaction and submit it to the network', () => {
    const mnemonic = Utils.generateMnemonic()
    const keyManager = InMemoryKeyManager({ mnemonic, password })
    const { transaction, inputs } = generateTestTransaction(keyManager.publicAccount())
    const signedTransaction = keyManager.signTransaction(transaction, inputs)

    expect(connect(mockProvider).submitTransaction(signedTransaction)).to.eql(true)
  })
})
