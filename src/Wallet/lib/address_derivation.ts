import { AddressType } from '..'
import { Provider } from '../../Provider'
import { getNextAddressByType } from '.'
import { SCAN_GAP } from '../config'
import { addressDiscoveryWithinBounds } from '../../Utils'
import { Cardano, ChainSettings } from '../../Cardano'

export async function deriveAddressSet (cardano: Cardano, provider: Provider, account: string) {
  const nextReceivingAddress = await getNextAddressByType(cardano, provider, account, AddressType.external)
  const nextChangeAddress = await getNextAddressByType(cardano, provider, account, AddressType.internal)

  const receiptAddresses = addressDiscoveryWithinBounds(cardano, {
    account,
    lowerBound: 0,
    upperBound: nextReceivingAddress.index + SCAN_GAP - 1,
    type: AddressType.external
  }, ChainSettings.mainnet)

  const changeAddresses = addressDiscoveryWithinBounds(cardano, {
    account,
    lowerBound: 0,
    upperBound: nextChangeAddress.index + SCAN_GAP - 1,
    type: AddressType.internal
  }, ChainSettings.mainnet)

  return receiptAddresses.concat(changeAddresses)
}
