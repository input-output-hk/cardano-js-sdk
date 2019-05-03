import { expect } from 'chai'
import { addressDiscoveryWithinBounds, AddressType } from './address_discovery'
import { MemoryKeyManager } from '../../KeyManager'
import { generateMnemonic } from '../../utils'

describe('addressDiscovery', () => {
  const mnemonic = generateMnemonic()
  const account = MemoryKeyManager({ mnemonic, password: 'foobar' }).publicAccount()

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
