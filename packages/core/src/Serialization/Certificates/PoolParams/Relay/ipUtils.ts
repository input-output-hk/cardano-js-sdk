/* eslint-disable no-bitwise */
import { InvalidArgumentError } from '@cardano-sdk/util';

const IPV4_OCTET = /^\d{1,3}$/;
const IPV6_HEXTET = /^[\dA-Fa-f]{1,4}$/;

/** Parses an IPv4 string into its four octets, or returns `null` if it is not a valid IPv4 address. */
const parseIpV4Octets = (address: string): number[] | null => {
  const parts = address.split('.');
  if (parts.length !== 4) return null;
  const octets = parts.map((part) => (IPV4_OCTET.test(part) ? Number.parseInt(part, 10) : -1));
  return octets.every((octet) => octet >= 0 && octet <= 0xff) ? octets : null;
};

/**
 * Parses one side of an IPv6 address (the part before or after `::`) into its 16-bit groups,
 * or returns `null` if it is malformed. A trailing IPv4-mapped suffix is expanded into two groups.
 */
const parseIpV6GroupTokens = (part: string): number[] | null => {
  if (part === '') return [];
  const groups: number[] = [];
  const tokens = part.split(':');
  for (let i = 0; i < tokens.length; i++) {
    const token = tokens[i];
    if (token.includes('.')) {
      // an embedded IPv4 address is only valid as the final token
      if (i !== tokens.length - 1) return null;
      const octets = parseIpV4Octets(token);
      if (!octets) return null;
      groups.push((octets[0] << 8) | octets[1], (octets[2] << 8) | octets[3]);
    } else {
      if (!IPV6_HEXTET.test(token)) return null;
      groups.push(Number.parseInt(token, 16));
    }
  }
  return groups;
};

/**
 * Parses an IPv6 string into its fully expanded 16-byte big-endian representation, or returns
 * `null` if it is not a valid IPv6 address. Handles `::` zero-compression and a trailing
 * IPv4-mapped suffix (e.g. `::ffff:10.3.2.10`).
 */
const parseIpV6Bytes = (address: string): Uint8Array | null => {
  if (address.length === 0) return null;
  const halves = address.split('::');
  if (halves.length > 2) return null;

  const head = parseIpV6GroupTokens(halves[0]);
  if (!head) return null;

  let groups: number[];
  if (halves.length === 1) {
    if (head.length !== 8) return null;
    groups = head;
  } else {
    const tail = parseIpV6GroupTokens(halves[1]);
    if (!tail) return null;
    const fill = 8 - head.length - tail.length;
    // `::` must collapse at least one zero group
    if (fill < 1) return null;
    groups = [...head, ...Array.from({ length: fill }, () => 0), ...tail];
  }

  const bytes = new Uint8Array(16);
  for (let i = 0; i < 8; i++) {
    bytes[i * 2] = (groups[i] >> 8) & 0xff;
    bytes[i * 2 + 1] = groups[i] & 0xff;
  }
  return bytes;
};

/**
 * Converts a IPv4 string to its byte array representation.
 *
 * @param address A string representing an IPv4 address.
 * @returns The IPv4 byte array.
 */
export const ipV4StringToByteArray = (address: string): Uint8Array => {
  const octets = parseIpV4Octets(address);
  if (!octets) throw new InvalidArgumentError('address', `Invalid IP V4 string: ${address}`);

  return new Uint8Array(octets);
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
  const bytes = parseIpV6Bytes(address);
  if (!bytes) throw new InvalidArgumentError('address', `Invalid IP V6 string: ${address}`);

  return bytes;
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
  const groups: string[] = [];
  for (let i = 0; i < 16; i += 2)
    groups.push((((byteArray[i] << 8) | byteArray[i + 1]) >>> 0).toString(16).padStart(4, '0'));

  return groups.join(':');
};
