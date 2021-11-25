/* eslint-disable @typescript-eslint/no-explicit-any */
import { Hash16, OpaqueString, assertIsBech32WithPrefix, assertIsHexString } from '../../util';

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
export type PoolIdHex = OpaqueString<'PoolIdHex'>;

/**
 * @param {string} value operator verification key hash as hex string
 * @throws InvalidStringError
 */
export const PoolIdHex = (value: string): PoolIdHex => {
  assertIsHexString(value, 56);
  return value as any as PoolIdHex;
};

/**
 * Ed25519 key hash as hex string
 */
export type Ed25519KeyHash = OpaqueString<'Ed25519KeyHash'>;

/**
 * @param {string} value Ed25519 key hash as hex string
 * @throws InvalidStringError
 */
export const Ed25519KeyHash = (value: string): Ed25519KeyHash => {
  assertIsHexString(value, 56);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return value as any as Ed25519KeyHash;
};

/**
 * VRF key hash as hex string
 */
export type VrfKeyHash = Hash16<'VrfKeyHash'>;

/**
 * @param {string} value VRF key hash as hex string
 * @throws InvalidStringError
 */
export const VrfKeyHash = (value: string): VrfKeyHash => Hash16<'VrfKeyHash'>(value);
