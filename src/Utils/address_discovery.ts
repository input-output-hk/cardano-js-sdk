import { AddressType } from '../Wallet'
import { RustCardano } from '../Cardano'
import { ChainSettings } from '../Cardano/Primitives'

/** BIP44 specifies that discovery should occur for an address type in batches of 20, until no balances exist */
export function addressDiscoveryWithinBounds({ type, account, lowerBound, upperBound, accountIndex }: {
  type: AddressType,
  account: string,
  lowerBound: number,
  upperBound: number
  accountIndex?: number,
}, chainSettings = ChainSettings.mainnet, cardano = RustCardano) {
  if (!accountIndex) {
    accountIndex = 0
  }

  const addressIndices = Array(upperBound - lowerBound + 1)
    .fill(0)
    .map((_, idx) => lowerBound + idx)

  return addressIndices.map(index => cardano.address({ publicAccount: account, index, type, accountIndex }, chainSettings))
}
