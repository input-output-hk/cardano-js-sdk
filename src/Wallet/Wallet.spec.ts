import { expect } from 'chai'
import { Cardano } from '../Cardano'
import { ProviderType, CardanoProvider, WalletProvider } from '../Provider'
import { Wallet } from './Wallet'
import { InvalidWalletArguments } from './errors'

describe('Wallet', () => {
  it('throws if a publicParentKey is not provided when interfacing with a cardano provider', () => {
    const cardano = {} as Cardano
    const cardanoProvider = {
      type: ProviderType.cardano
    } as CardanoProvider

    const call = () => Wallet(cardano, cardanoProvider)({ walletId: 'x' })
    expect(call).to.throw(InvalidWalletArguments)
  })

  it('throws if a walletId is not provided when interfacing with a wallet provider', () => {
    const cardano = {} as Cardano
    const walletProvider = {
      type: ProviderType.wallet
    } as WalletProvider

    const call = () => Wallet(cardano, walletProvider)({ publicParentKey: 'x' })
    expect(call).to.throw(InvalidWalletArguments)
  })
})
