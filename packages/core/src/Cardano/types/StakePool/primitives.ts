/* eslint-disable @typescript-eslint/no-explicit-any */
import * as BaseEncoding from '@scure/base';
import * as Crypto from '@cardano-sdk/crypto';
import { HexBlob, OpaqueString, typedBech32, typedHex } from '@cardano-sdk/util';

const MAX_BECH32_LENGTH_LIMIT = 1023;

/** pool operator verification key hash as bech32 string or a genesis pool ID */
export type PoolId = OpaqueString<'PoolId'>;

/**
 * @param {string} value blake2b_224 digest of an operator verification key hash
 * @throws InvalidStringError
 */
export const PoolId = (value: string): PoolId => typedBech32(value, 'pool', 45);

/**
 * @param {string} value blake2b_224 digest of an operator verification key hash
 * @throws InvalidStringError
 */
PoolId.fromKeyHash = (value: Crypto.Ed25519KeyHashHex): PoolId => HexBlob.toTypedBech32('pool', value);

/** /** pool operator verification key hash as hex string */
export type PoolIdHex = OpaqueString<'PoolIdHex'>;

/**
 * @param {string} value operator verification key hash as hex string
 * @throws InvalidStringError
 */
export const PoolIdHex = (value: string): PoolIdHex => Crypto.Hash28ByteBase16(value) as unknown as PoolIdHex;

/** 32 byte VRF verification key as hex string */
export type VrfVkHex = OpaqueString<'VrfVkHex'>;
export const VrfVkHex = (target: string): VrfVkHex => typedHex(target, 64);

/**
 * Converts a pool id into its key hash.
 *
 * @param poolId The pool id to be converted.
 */
PoolId.toKeyHash = (poolId: PoolId): Crypto.Ed25519KeyHashHex => {
  const { words } = BaseEncoding.bech32.decode(poolId, MAX_BECH32_LENGTH_LIMIT);
  return Crypto.Ed25519KeyHashHex(HexBlob.fromBytes(BaseEncoding.bech32.fromWords(words)));
};
