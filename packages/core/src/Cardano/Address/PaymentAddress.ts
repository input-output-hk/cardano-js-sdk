import { Address, AddressType } from './Address';
import { DRepID } from './DRepID';
import {
  HexBlob,
  InvalidStringError,
  OpaqueString,
  assertIsBech32WithPrefix,
  assertIsHexString
} from '@cardano-sdk/util';
import type { HydratedTx, Tx } from '../types/Transaction';
import type { HydratedTxIn, TxIn, TxOut } from '../types/Utxo';
import type { NetworkId } from '../ChainId';
import type { RewardAccount } from './RewardAccount';

/** mainnet or testnet address (Shelley as bech32 string, Byron as base58-encoded string) */
export type PaymentAddress = OpaqueString<'PaymentAddress'>;

/**
 * @param {string} address mainnet or testnet address
 * @throws InvalidStringError
 */
export const isRewardAccount = (address: string) => {
  try {
    assertIsBech32WithPrefix(address, ['stake', 'stake_test']);
    return true;
  } catch {
    return false;
  }
};

/**
 * Transform a `value` into `Cardano.PaymentAddress`,
 * Resulting PaymentAddress will be base58 in case of Byron era or bech32 in case of Shelley era or newer.
 *
 * @param value bech32 string, base58 string or hex-encoded bytes address.
 * @throws {InvalidStringError} if value is invalid
 */
export const PaymentAddress = (value: string): PaymentAddress => {
  if (Address.isValid(value)) {
    if (isRewardAccount(value) || DRepID.isValid(value)) {
      throw new InvalidStringError(value, 'Address type can only be used for payment addresses');
    }
    return value as unknown as PaymentAddress;
  }

  try {
    assertIsHexString(value);
  } catch {
    throw new InvalidStringError(value, 'Expected payment address as bech32, base58 or hex-encoded bytes');
  }

  const address = Address.fromBytes(HexBlob.fromBytes(Buffer.from(value, 'hex')));

  return (address.getType() === AddressType.Byron ? address.toBase58() : address.toBech32()) as PaymentAddress;
};

/** Checks that an object containing an address (e.g., output, input) is within a set of provided addresses */
export const isAddressWithin =
  (addresses: PaymentAddress[]) =>
  ({ address }: { address: PaymentAddress }): boolean =>
    addresses.includes(address!);

/**
 * Receives a transaction and a set of addresses to check if
 * some of them are included in the transaction inputs
 *
 * @returns {HydratedTxIn[]} array of inputs that contain any of the addresses
 */
export const inputsWithAddresses = (tx: HydratedTx, ownAddresses: PaymentAddress[]): HydratedTxIn[] =>
  tx.body.inputs.filter(isAddressWithin(ownAddresses));

export type ResolveOptions = {
  hints: Tx[];
};

/**
 * @param txIn transaction input to resolve associated txOut from
 * @returns txOut
 */
export type ResolveInput = (txIn: TxIn, options?: ResolveOptions) => Promise<TxOut | null>;

export interface InputResolver {
  resolveInput: ResolveInput;
}

/**
 * Gets the network id from the address.
 *
 * @param address The address to get the network id from.
 * @returns The network ID.
 */
export const addressNetworkId = (address: RewardAccount | PaymentAddress | DRepID): NetworkId => {
  const addr = Address.fromString(address);
  return addr!.getNetworkId();
};
