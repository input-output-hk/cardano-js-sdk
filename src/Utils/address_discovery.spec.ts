import { expect } from 'chai'
import { generateMnemonic } from './mnemonic'
import { AddressType } from '../Wallet'
import { addressDiscoveryWithinBounds } from './address_discovery'
import { InMemoryKeyManager, RustCardano } from '../lib'
import { ChainSettings } from '../Cardano'

describe('addressDiscovery', () => {
  let mnemonic: string
  let account: string

  beforeEach(async () => {
    mnemonic = generateMnemonic()
    account = await InMemoryKeyManager(RustCardano, { mnemonic, password: 'foobar' }).publicParentKey()
  })

  it('correctly returns address indexes and address type', () => {
    const internalAddresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.internal, lowerBound: 0, upperBound: 19 }, ChainSettings.mainnet)
    expect(internalAddresses[0].index).to.eql(0)
    expect(internalAddresses[0].type).to.eql(AddressType.internal)

    const externalAddresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.external, lowerBound: 0, upperBound: 19 }, ChainSettings.mainnet)
    expect(externalAddresses[0].index).to.eql(0)
    expect(externalAddresses[0].type).to.eql(AddressType.external)
  })

  describe('internal', () => {
    it('discovers addresses between bounds', () => {
      const internalAddresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.internal, lowerBound: 0, upperBound: 19 }, ChainSettings.mainnet)
      expect(internalAddresses.length).to.eql(20)
    })

    it('does not collide between different bounds', () => {
      const first20Addresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.internal, lowerBound: 0, upperBound: 19 }, ChainSettings.mainnet)
      const next20Addresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.internal, lowerBound: 20, upperBound: 39 }, ChainSettings.mainnet)
      const addressSet = new Set(first20Addresses.concat(next20Addresses))
      expect([...addressSet].length).to.eql(40)
    })

    it('does not collide with external addresses', () => {
      const internalAddresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.internal, lowerBound: 0, upperBound: 19 }, ChainSettings.mainnet)
      const externalAddresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.external, lowerBound: 0, upperBound: 19 }, ChainSettings.mainnet)
      const addressSet = new Set(internalAddresses.concat(externalAddresses))
      expect([...addressSet].length).to.eql(40)
    })
  })

  describe('external', () => {
    it('discovers addresses between bounds', () => {
      const externalAddresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.external, lowerBound: 0, upperBound: 19 }, ChainSettings.mainnet)
      expect(externalAddresses.length).to.eql(20)
    })

    it('does not collide between different bounds', () => {
      const first20Addresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.external, lowerBound: 0, upperBound: 19 }, ChainSettings.mainnet)
      const next20Addresses = addressDiscoveryWithinBounds(RustCardano, { account, type: AddressType.external, lowerBound: 20, upperBound: 39 }, ChainSettings.mainnet)
      const addressSet = new Set(first20Addresses.concat(next20Addresses))
      expect([...addressSet].length).to.eql(40)
    })
  })
})
