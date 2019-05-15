import { seed } from './utils/seed'
import { expect, use } from 'chai'
import * as chaiAsPromised from 'chai-as-promised'
import { InMemoryKeyManager, connect } from '..'
import { mockProvider, seedMockProvider } from './utils/mock_provider'
use(chaiAsPromised)

describe('Example: Select inputs for transaction', () => {
  it('returns transaction inputs and a change output', async () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account1
    const keyManager = InMemoryKeyManager({ mnemonic, password: '' })
    const wallet = connect(mockProvider).wallet(keyManager.publicAccount())

    const mnemonic2 = seed.accountMnemonics.account2
    const keyManager2 = InMemoryKeyManager({ mnemonic: mnemonic2, password: '' })
    const targetOutputAddress = await connect(mockProvider).wallet(keyManager2.publicAccount()).getNextReceivingAddress()

    const { inputs, changeOutput } = await wallet.selectInputsForTransaction([
      { value: '100', address: targetOutputAddress.address }
    ])

    expect(inputs.length).to.eql(1)
    expect(inputs[0].value.value).to.eql('200000')

    const { address } = await wallet.getNextChangeAddress()
    expect(changeOutput.address).to.eql(address)
  })

  it('fails for an account with insufficient utxos', async () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account2
    const keyManager = InMemoryKeyManager({ mnemonic, password: '' })
    const wallet = connect(mockProvider).wallet(keyManager.publicAccount())

    const mnemonic2 = seed.accountMnemonics.account1
    const keyManager2 = InMemoryKeyManager({ mnemonic: mnemonic2, password: '' })
    const targetOutputAddress = await connect(mockProvider).wallet(keyManager2.publicAccount()).getNextReceivingAddress()

    const call = wallet.selectInputsForTransaction([
      { value: '100', address: targetOutputAddress.address }
    ])

    return expect(call).to.eventually.be.rejectedWith('NotEnoughInput')
  })
})
