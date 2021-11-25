/* eslint-disable @typescript-eslint/no-explicit-any */
import { Hash28ByteBase16, Hash32ByteBase16, OpaqueString, assertIsBech32WithPrefix } from '../../util';

/**
 * pool operator verification key hash as bech32 string
 */
export type PoolId = OpaqueString<'PoolId'>;

/**
 * @param {string} value blake2b_224 digest of an operator verification key hash
 * @throws InvalidStringError
 */
export const PoolId = (value: string): PoolId => {
  assertIsBech32WithPrefix(value, 'pool', 45);
  return value as any as PoolId;
};

/**
 * pool operator verification key hash as hex string
 */
export type PoolIdHex = Hash28ByteBase16<'PoolIdHex'>;

/**
 * @param {string} value operator verification key hash as hex string
 * @throws InvalidStringError
 */
export const PoolIdHex = (value: string): PoolIdHex => Hash28ByteBase16(value);

/**
 * VRF key hash as hex string
 */
export type VrfKeyHash = Hash32ByteBase16<'VrfKeyHash'>;

/**
 * @param {string} value VRF key hash as hex string
 * @throws InvalidStringError
 */
export const VrfKeyHash = (value: string): VrfKeyHash => Hash32ByteBase16<'VrfKeyHash'>(value);
