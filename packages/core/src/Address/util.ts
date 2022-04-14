import { Address, TxAlonzo } from '../Cardano';
import { parseCslAddress } from '../CSL';

/**
 * Validate input as a Cardano Address from all Cardano eras and networks
 */
export const isAddress = (input: string): boolean => !!parseCslAddress(input);

/**
 * Checks that an object containing an address (e.g., output, input) is within a set of provided addresses
 */
export const isAddressWithin =
  (addresses: Address[]) =>
  ({ address }: { address: Address }): boolean =>
    addresses.includes(address!);

/**
 * Receives a transaction and a set of addresses to check if the transaction is outgoing,
 * i.e., some of the addresses are included in the transaction inputs
 */
export const isOutgoing = (tx: TxAlonzo, ownAddresses: Address[]): boolean =>
  tx.body.inputs.some(isAddressWithin(ownAddresses));
