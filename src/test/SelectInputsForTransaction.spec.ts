import { seed } from './utils/seed'
import { expect, use } from 'chai'
import * as chaiAsPromised from 'chai-as-promised'
import { InMemoryKeyManager, connect } from '..'
import { mockProvider, seedMockProvider } from './utils/mock_provider'
import { InsufficientValueInUtxosForSelection } from '../Wallet/errors'
use(chaiAsPromised)

describe('Example: Select inputs for transaction', () => {
  it('returns transaction inputs and a change output', async () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account1
    const keyManager = InMemoryKeyManager({ mnemonic, password: '' })
    const wallet = connect(mockProvider).wallet(keyManager.publicAccount())

    const { inputs, changeOutput } = await wallet.selectInputsForTransaction([
      { value: '100', address: 'foobar' }
    ], '10000')

    expect(inputs.length).to.eql(1)
    expect(inputs[0].value.value).to.eql('1000000')

    const { address } = await wallet.getNextChangeAddress()
    expect(changeOutput.address).to.eql(address)
  })

  it('fails for an account with insufficient utxos', () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account3
    const keyManager = InMemoryKeyManager({ mnemonic, password: '' })
    const wallet = connect(mockProvider).wallet(keyManager.publicAccount())

    const call = wallet.selectInputsForTransaction([
      { value: '100', address: 'foobar' }
    ], '10000')

    return expect(call).to.eventually.be.rejectedWith(InsufficientValueInUtxosForSelection)
  })
})
