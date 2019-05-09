import { Bip44AccountPublic } from 'cardano-wallet'
import { getBindingsForEnvironment } from '../../lib/bindings'
const { AddressKeyIndex, BlockchainSettings } = getBindingsForEnvironment()

/** internal = change address & external = receipt address */
export enum AddressType {
  internal = 'Internal',
  external = 'External'
}

/** BIP44 specifies that discovery should occur for an address type in batches of 20, until no balances exist */
export function addressDiscoveryWithinBounds ({ type, account, lowerBound, upperBound }: {
  type: AddressType,
  account: Bip44AccountPublic,
  lowerBound: number,
  upperBound: number
}, chainSettings = BlockchainSettings.mainnet()) {
  const addressIndices = Array(upperBound - lowerBound + 1)
    .fill(0)
    .map((_, idx) => lowerBound + idx)

  return addressIndices.map(index => {
    const pubKey = account.address_key(
      type === AddressType.internal,
      AddressKeyIndex.new(index)
    )

    const address = pubKey.bootstrap_era_address(chainSettings)
    return {
      address: address.to_base58(),
      index: lowerBound + index,
      type
    }
  })
}
