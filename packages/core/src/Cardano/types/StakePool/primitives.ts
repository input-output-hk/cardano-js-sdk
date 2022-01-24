/* eslint-disable @typescript-eslint/no-explicit-any */
import { Hash28ByteBase16, OpaqueString, typedBech32, typedHex } from '../../util';

/**
 * pool operator verification key hash as bech32 string or a genesis pool ID
 */
export type PoolId = OpaqueString<'PoolId'>;

/**
 * @param {string} value blake2b_224 digest of an operator verification key hash
 * @throws InvalidStringError
 */
export const PoolId = (value: string): PoolId => typedBech32(value, 'pool', 45);

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
 * 32 byte VRF verification key as hex string
 */
export type VrfVkHex = OpaqueString<'VrfVkHex'>;
export const VrfVkHex = (target: string): VrfVkHex => typedHex(target, 64);
