import { seed } from './utils/seed'
import { expect } from 'chai'
import { InMemoryKeyManager, connect } from '..'
import { mockProvider, seedMockProvider } from './utils/mock_provider'

describe('Example: Determine the balance for a PublicAccount, in Lovelace', () => {
  it('returns a positive number for an account with UTXOs', async () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account1
    const keyManager = InMemoryKeyManager({ mnemonic, password: '' })
    const publicAccount = await keyManager.publicAccount()

    const balance = await connect(mockProvider).wallet(publicAccount).balance()
    expect(balance).to.eql(200000 * 6)
  })

  it('returns 0 for a new account', async () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account2
    const keyManager = InMemoryKeyManager({ mnemonic, password: '' })
    const publicAccount = await keyManager.publicAccount()

    const balance = await connect(mockProvider).wallet(publicAccount).balance()
    expect(balance).to.eql(0)
  })
})
