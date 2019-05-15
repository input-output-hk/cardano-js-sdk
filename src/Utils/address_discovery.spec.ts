import { expect } from 'chai'
import { InMemoryKeyManager } from '../KeyManager'
import { generateMnemonic } from './mnemonic'
import { AddressType } from '../Wallet'
import { addressDiscoveryWithinBounds } from './address_discovery'

describe('addressDiscovery', () => {
  const mnemonic = generateMnemonic()
  const account = InMemoryKeyManager({ mnemonic, password: 'foobar' }).publicAccount()

  it('correctly returns address indexes and address type', () => {
    const internalAddresses = addressDiscoveryWithinBounds({ account, type: AddressType.internal, lowerBound: 0, upperBound: 19 })
    expect(internalAddresses[0].index).to.eql(0)
    expect(internalAddresses[0].type).to.eql(AddressType.internal)

    const externalAddresses = addressDiscoveryWithinBounds({ account, type: AddressType.external, lowerBound: 0, upperBound: 19 })
    expect(externalAddresses[0].index).to.eql(0)
    expect(externalAddresses[0].type).to.eql(AddressType.external)
  })

  describe('internal', () => {
    it('discovers addresses between bounds', () => {
      const internalAddresses = addressDiscoveryWithinBounds({ account, type: AddressType.internal, lowerBound: 0, upperBound: 19 })
      expect(internalAddresses.length).to.eql(20)
    })

    it('does not collide between different bounds', () => {
      const first20Addresses = addressDiscoveryWithinBounds({ account, type: AddressType.internal, lowerBound: 0, upperBound: 19 })
      const next20Addresses = addressDiscoveryWithinBounds({ account, type: AddressType.internal, lowerBound: 20, upperBound: 39 })
      const addressSet = new Set(first20Addresses.concat(next20Addresses))
      expect([...addressSet].length).to.eql(40)
    })

    it('does not collide with external addresses', () => {
      const internalAddresses = addressDiscoveryWithinBounds({ account, type: AddressType.internal, lowerBound: 0, upperBound: 19 })
      const externalAddresses = addressDiscoveryWithinBounds({ account, type: AddressType.external, lowerBound: 0, upperBound: 19 })
      const addressSet = new Set(internalAddresses.concat(externalAddresses))
      expect([...addressSet].length).to.eql(40)
    })
  })

  describe('external', () => {
    it('discovers addresses between bounds', () => {
      const externalAddresses = addressDiscoveryWithinBounds({ account, type: AddressType.external, lowerBound: 0, upperBound: 19 })
      expect(externalAddresses.length).to.eql(20)
    })

    it('does not collide between different bounds', () => {
      const first20Addresses = addressDiscoveryWithinBounds({ account, type: AddressType.external, lowerBound: 0, upperBound: 19 })
      const next20Addresses = addressDiscoveryWithinBounds({ account, type: AddressType.external, lowerBound: 20, upperBound: 39 })
      const addressSet = new Set(first20Addresses.concat(next20Addresses))
      expect([...addressSet].length).to.eql(40)
    })
  })
})
