import { expect } from 'chai'
import CardanoSdk from '..'
import { generateTestTransaction } from './utils/test_transaction'
import { mockProvider } from './utils/mock_provider'

describe('Example: Memory Key Manager', () => {
  const password = 'secure'

  it('allows a user to create a new memory key from a valid mnemonic, sign a transaction and submit it to the network', () => {
    const mnemonic = CardanoSdk.Utils.generateMnemonic()
    const keyManager = CardanoSdk.MemoryKeyManager({ mnemonic, password })
    const { transaction, inputs } = generateTestTransaction(keyManager.publicAccount())
    const signedTransaction = keyManager.signTransaction(transaction, inputs)

    expect(new CardanoSdk(mockProvider).submitTransaction(signedTransaction)).to.eql(true)
  })
})
