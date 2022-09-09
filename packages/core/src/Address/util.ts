import { Address, NewTxIn, TxAlonzo, TxIn } from '../Cardano';
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
 * Receives a transaction and a set of addresses to check if
 * some of them are included in the transaction inputs
 *
 * @returns {TxIn[]} array of inputs that contain any of the addresses
 */
export const inputsWithAddresses = (tx: TxAlonzo, ownAddresses: Address[]): TxIn[] =>
  tx.body.inputs.filter(isAddressWithin(ownAddresses));

/**
 * @param txIn transaction input to resolve address from
 * @returns input owner address
 */
export type ResolveInputAddress = (txIn: NewTxIn) => Promise<Address | null>;

export interface InputResolver {
  resolveInputAddress: ResolveInputAddress;
}
