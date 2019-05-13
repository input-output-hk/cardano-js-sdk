import { seed } from './utils/seed'
import { expect } from 'chai'
import { InMemoryKeyManager, connect } from '..'
import { mockProvider, seedMockProvider } from './utils/mock_provider'

describe('Example: Determine the balance for a PublicAccount, in Lovelace', () => {
  it('returns a positive number for an account with utxos', async () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account1
    const keyManager = InMemoryKeyManager({ mnemonic, password: '' })

    const balance = await connect(mockProvider).wallet(keyManager.publicAccount()).balance()
    expect(balance).to.eql(10000000)
  })

  it('returns 0 for a new account', async () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account3
    const keyManager = InMemoryKeyManager({ mnemonic, password: '' })

    const balance = await connect(mockProvider).wallet(keyManager.publicAccount()).balance()
    expect(balance).to.eql(0)
  })
})
