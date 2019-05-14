import { AddressType, addressDiscoveryWithinBounds } from '../../Wallet'
import { Bip44AccountPublic } from 'cardano-wallet'
import { hexGenerator } from '.'

export function generateTestUtxos ({ account, lowerBound, upperBound, type, value }: { account: Bip44AccountPublic, lowerBound: number, upperBound: number, type: AddressType, value: string }) {
  const numberOfUtxos = upperBound - lowerBound
  return [...Array(numberOfUtxos)].map((_, index) => {
    const address = addressDiscoveryWithinBounds({
      account,
      type,
      lowerBound: index + lowerBound,
      upperBound: index + lowerBound
    })[0].address

    return { value, address, id: hexGenerator(64), index }
  })
}
