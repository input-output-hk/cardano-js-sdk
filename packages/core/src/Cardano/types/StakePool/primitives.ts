/* eslint-disable @typescript-eslint/no-explicit-any */
import * as util from '../../util';

/**
 * pool operator verification key hash as bech32 string
 */
export type PoolId = util.OpaqueString<'PoolId'>;

/**
 * @param {string} value blake2b_224 digest of an operator verification key hash
 * @throws InvalidStringError
 */
export const PoolId = (value: string): PoolId => {
  util.assertIsBech32WithPrefix(value, 'pool', 45);
  return value as any as PoolId;
};

/**
 * pool operator verification key hash as hex string
 */
export type PoolIdHex = util.OpaqueString<'PoolIdHex'>;

/**
 * @param {string} value operator verification key hash as hex string
 * @throws InvalidStringError
 */
export const PoolIdHex = (value: string): PoolIdHex => {
  util.assertIsHexString(value, 56);
  return value as any as PoolIdHex;
};
