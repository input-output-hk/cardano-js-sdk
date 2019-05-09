import { Bip44AccountPublic } from 'cardano-wallet'
import { AddressType, addressDiscoveryWithinBounds } from '..'
import { Provider } from '../../Provider'
import { getNextAddressByType } from '.'

export async function deriveAddressSet (provider: Provider, account: Bip44AccountPublic) {
  const nextReceivingAddress = await getNextAddressByType(provider, account, AddressType.external)
  const nextChangeAddress = await getNextAddressByType(provider, account, AddressType.internal)

  const receiptAddresses = addressDiscoveryWithinBounds({
    account,
    lowerBound: 0,
    upperBound: nextReceivingAddress.index,
    type: AddressType.external
  })

  const changeAddresses = addressDiscoveryWithinBounds({
    account,
    lowerBound: 0,
    upperBound: nextChangeAddress.index,
    type: AddressType.internal
  })

  return receiptAddresses.concat(changeAddresses)
}
