import { Bip44AccountPublic } from 'cardano-wallet'
import { AddressType, addressDiscoveryWithinBounds } from '..'
import { SCAN_GAP } from '../config'
import { Provider } from '../../Provider'
import { getNextAddressByType } from '.'

function deriveAddressesUntilAddressIsFound(
  account: Bip44AccountPublic,
  address: string,
  type: AddressType,
  accumulatedAddresses: string[] = [],
  lowerBound = 0,
  upperBound = SCAN_GAP - 1,
  maxScan = 10000
): string[] {
  if (accumulatedAddresses.length > maxScan) {
    throw new Error('Maximum scan reach')
  }

  const addresses = addressDiscoveryWithinBounds({
    account,
    lowerBound,
    upperBound,
    type
  })

  const addressInRange = addresses.some(a => a === address)

  if (!addressInRange) {
    const newAccumulationOfAddresses = accumulatedAddresses.concat(addresses)
    return deriveAddressesUntilAddressIsFound(account, address, type, newAccumulationOfAddresses, lowerBound + SCAN_GAP, upperBound + SCAN_GAP, maxScan)
  }

  const indexOfAddress = addresses.findIndex(a => a === address)
  return accumulatedAddresses.concat(address.slice(0, indexOfAddress + 1))
}

export async function deriveCurrentAddressSet(provider: Provider, account: Bip44AccountPublic) {
  const nextReceivingAddress = await getNextAddressByType(provider, account, AddressType.external)
  const nextChangeAddress = await getNextAddressByType(provider, account, AddressType.internal)

  const receiptAddressesWithTransactions = deriveAddressesUntilAddressIsFound(account, nextReceivingAddress, AddressType.external)
  const changeAddressesWithTransactions = deriveAddressesUntilAddressIsFound(account, nextChangeAddress, AddressType.external)

  return receiptAddressesWithTransactions.concat(changeAddressesWithTransactions)
}