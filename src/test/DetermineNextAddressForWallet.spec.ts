import { seed } from './utils/seed'
import { expect } from 'chai'
import CardanoSDK from '..'
import { mockProvider, seedMockProvider } from './utils/mock_provider'
import { AddressType } from '../Wallet'
import { addressDiscoveryWithinBounds } from '../Utils'
import { RustCardano } from '../lib'
import { ChainSettings } from '../Cardano'

describe('Example: Key Derivation', () => {
  let cardano: ReturnType<typeof CardanoSDK>
  beforeEach(() => {
    cardano = CardanoSDK()
  })

  it('allows a user to determine their next receipt address', async () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account1
    const keyManager = cardano.InMemoryKeyManager({ mnemonic, password: '' })
    const publicAccount = await keyManager.publicParentKey()

    const { address } = await cardano.connect(mockProvider).wallet({ publicParentKey: publicAccount }).getNextReceivingAddress()
    const nextAddressBasedOnSeedContext = addressDiscoveryWithinBounds(RustCardano, {
      account: (await keyManager.publicParentKey()),
      lowerBound: 16,
      upperBound: 16,
      type: AddressType.external
    }, ChainSettings.mainnet)[0].address

    expect(nextAddressBasedOnSeedContext).to.eql(address)
  })

  it('allows a user to determine their next change address', async () => {
    seedMockProvider(seed.utxos, seed.transactions)

    const mnemonic = seed.accountMnemonics.account1
    const keyManager = cardano.InMemoryKeyManager({ mnemonic, password: '' })
    const publicAccount = await keyManager.publicParentKey()

    const { address } = await cardano.connect(mockProvider).wallet({ publicParentKey: publicAccount }).getNextChangeAddress()
    const nextAddressBasedOnSeedContext = addressDiscoveryWithinBounds(RustCardano, {
      account: publicAccount,
      lowerBound: 0,
      upperBound: 0,
      type: AddressType.internal
    }, ChainSettings.mainnet)[0].address

    expect(nextAddressBasedOnSeedContext).to.eql(address)
  })
})
