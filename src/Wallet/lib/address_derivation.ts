import { AddressType } from '..'
import { Provider } from '../../Provider'
import { getNextAddressByType } from '.'
import { SCAN_GAP } from '../config'
import { addressDiscoveryWithinBounds } from '../../Utils'

export async function deriveAddressSet(provider: Provider, account: string) {
  const nextReceivingAddress = await getNextAddressByType(provider, account, AddressType.external)
  const nextChangeAddress = await getNextAddressByType(provider, account, AddressType.internal)

  const receiptAddresses = addressDiscoveryWithinBounds({
    account,
    lowerBound: 0,
    upperBound: nextReceivingAddress.index + SCAN_GAP - 1,
    type: AddressType.external
  })

  const changeAddresses = addressDiscoveryWithinBounds({
    account,
    lowerBound: 0,
    upperBound: nextChangeAddress.index + SCAN_GAP - 1,
    type: AddressType.internal
  })

  return receiptAddresses.concat(changeAddresses)
}
