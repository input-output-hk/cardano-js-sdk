/* eslint-disable no-bitwise */
import { Address4, Address6 } from 'ip-address';
import { InvalidArgumentError } from '@cardano-sdk/util';

/**
 * Converts a IPv4 string to its byte array representation.
 *
 * @param address A string representing an IPv4 address.
 * @returns The IPv4 byte array.
 */
export const ipV4StringToByteArray = (address: string): Uint8Array => {
  if (!Address4.isValid(address)) throw new InvalidArgumentError('address', `Invalid IP V4 string: ${address}`);

  return new Uint8Array(address.split('.').map((segment) => Number.parseInt(segment)));
};

/**
 * Converts a IPv4 byte array to its string representation.
 *
 * @param byteArray A byte array representing an IPv4 address.
 * @returns The IPv4 string.
 */
export const byteArrayToIpV4String = (byteArray: Uint8Array): string => {
  if (byteArray.length !== 4)
    throw new InvalidArgumentError(
      'byteArray',
      `Invalid IP V4 byte array, expected 4 bytes, but got ${byteArray.length}`
    );
  // Uint8Array.map returns an Uint8Array object, so we need to convert it to a normal array first.
  return [...byteArray].map((octect) => octect.toString()).join('.');
};

/**
 * Converts a IPv6 string to its expanded byte array representation.
 * This function also handles IPv4-mapped IPv6 addresses.
 *
 * @param address A string representing an IPv6 address, which can be in shortened form.
 * @returns The fully expanded IPv6 byte array.
 */
export const ipV6StringToByteArray = (address: string): Uint8Array => {
  if (!Address6.isValid(address)) throw new InvalidArgumentError('address', `Invalid IP V6 string: ${address}`);

  // We need to fully expand the IPv6 byte array for serialization purposes.
  const addressV6 = new Address6(address).toUnsignedByteArray();
  const filler = Array.from({ length: 16 })
    .fill(0, 0, 16)
    .slice(0, 16 - addressV6.length) as Array<number>;

  return new Uint8Array([...filler, ...addressV6]);
};

/**
 * Converts a byte array representation of an IPv6 address into its string representation.
 *
 * This function will always yield the non-shortened version (Canonical form, collapsing empty segments
 * is not needed for anything other than display purposes).
 *
 * @param byteArray A Uint8Array containing 16 bytes that represent an IPv6 address.
 * @returns A string representing the IPv6 address in canonical form.
 */
export const byteArrayToIPv6String = (byteArray: Uint8Array): string => {
  const addressV6 = Address6.fromUnsignedByteArray([...byteArray]);

  return addressV6.canonicalForm();
};
