/* eslint-disable @typescript-eslint/no-explicit-any */
import { Hash28ByteBase16, OpaqueString, typedBech32, typedHex } from '../../util';
import { InvalidStringError } from '../../..';

/**
 * pool operator verification key hash as bech32 string or a genesis pool ID
 */
export type PoolId = OpaqueString<'PoolId'>;

/**
 * @param {string} value blake2b_224 digest of an operator verification key hash or a genesis pool ID
 * @throws InvalidStringError
 */
export const PoolId = (value: string): PoolId => {
  try {
    return typedBech32(value, 'pool', 45);
  } catch (error: unknown) {
    // eslint-disable-next-line prettier/prettier
    if ((/^ShelleyGenesis-[\dA-Fa-f]{16}$/).test(value)) {
      return value as unknown as PoolId;
    }
    throw new InvalidStringError('Expected PoolId to be either bech32 or genesis stake pool', error);
  }
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
 * 32 byte VRF verification key as hex string
 */
export type VrfVkHex = OpaqueString<'VrfVkHex'>;
export const VrfVkHex = (target: string): VrfVkHex => typedHex(target, 64);
