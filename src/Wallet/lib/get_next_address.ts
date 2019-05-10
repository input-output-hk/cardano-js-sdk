import { Provider } from '../../Provider'
import { Bip44AccountPublic } from 'cardano-wallet'
import { AddressType, addressDiscoveryWithinBounds, Address } from '..'
import { SCAN_GAP } from '../config'

export function getNextAddressByType (provider: Provider, account: Bip44AccountPublic, type: AddressType) {
  return scanBip44AccountForAddressWithoutTransactions({
    account,
    provider,
    lowerBound: 0,
    upperBound: SCAN_GAP - 1,
    type
  })
}

interface ScanRangeParameters {
  provider: Provider
  account: Bip44AccountPublic
  lowerBound: number
  upperBound: number
  type: AddressType
}

async function scanBip44AccountForAddressWithoutTransactions ({ provider, account, lowerBound, upperBound, type }: ScanRangeParameters): Promise<Address> {
  const addresses = addressDiscoveryWithinBounds({
    account,
    lowerBound,
    upperBound,
    type
  })

  const transactions = await provider.queryTransactionsByAddress(addresses.map(a => a.address))

  if (transactions.length === 0) {
    return addresses[0]
  }

  // Group transactions by address, if they have inputs for that address, meaning they are "used"
  // The transactions are now garunteed to be in address order, as they are grouped against the
  // address range
  const sortedTransactions: [Address, typeof transactions][] = addresses.map(address => {
    const transactionsByAddress = transactions.filter(transaction => {
      const transactionInputAddresses = transaction.inputs.map(input => input.value.address)
      return transactionInputAddresses.includes(address.address)
    })

    return [address, transactionsByAddress]
  })

  const reversedTransactions = sortedTransactions.reverse()
  const lastAddressWithTransactionsIndex = reversedTransactions.findIndex(([_address, transactions]) => {
    if (transactions.length > 0) {
      return true
    }
  })

  // If the first element in the scanned array (which is the reverse of the address range)
  // has transactions associated with it, then this range has been consumed
  if (lastAddressWithTransactionsIndex === 0) {
    return scanBip44AccountForAddressWithoutTransactions({
      provider,
      account,
      lowerBound: lowerBound + SCAN_GAP,
      upperBound: upperBound + SCAN_GAP,
      type
    })
  }

  return reversedTransactions[lastAddressWithTransactionsIndex - 1][0]
}
