/* eslint-disable max-len */
import { ExtendedStakePoolMetadata } from './ExtendedStakePoolMetadata';
import { Hash32ByteBase16, typedBech32 } from '@cardano-sdk/util';
import { Lovelace } from '../Value';
import { OpaqueString } from '@cardano-sdk/util';
import { PoolId, VrfVkHex } from './primitives';
import { Relay } from './Relay';
import { RewardAccount } from '../RewardAccount';

export interface Fraction {
  numerator: number;
  denominator: number;
}
export interface PoolMetadataJson {
  hash: Hash32ByteBase16;
  url: string;
}

/**
 * 32 byte ed25519 verification key as bech32 string with 'poolmd_vk' prefix.
 */
export type PoolMdVk = OpaqueString<'PoolMdVk'>;
export const PoolMdVk = (target: string): PoolMdVk => typedBech32(target, 'poolmd_vk', 52);

/**
 * https://github.com/cardano-foundation/CIPs/blob/master/CIP-0006/README.md
 */
export interface Cip6MetadataFields {
  /**
   * A URL for extended metadata
   * 128 Characters Maximum, must be a valid URL
   */
  extDataUrl?: string;
  /**
   * A URL with the extended metadata signature
   * 128 Characters Maximum, must be a valid URL
   */
  extSigUrl?: string;
  /**
   * the public Key for verification
   * optional, 68 Characters
   */
  extVkey?: PoolMdVk;
}

/**
 * https://raw.githubusercontent.com/cardanians/adapools.org/master/example-meta.json
 */
export interface APMetadataFields {
  /**
   * A URL for extended metadata
   * 128 Characters Maximum, must be a valid URL
   */
  extended?: string;
}

export interface StakePoolMainMetadataFields {
  /**
   * Pool ticker. uppercase
   * 5 Characters Maximum, Uppercase letters and numbers
   */
  ticker: string;
  /**
   * A name for the pool
   * 50 Characters Maximum
   */
  name: string;
  /**
   * Text that describes the pool
   * 50 Characters Maximum
   */
  description: string;
  /**
   * A website URL for the pool
   * 64 Characters Maximum, must be a valid URL
   */
  homepage: string;
}

export interface StakePoolExtendedMetadataFields {
  /**
   * Common stake pool extended metadata composed by CIP-6 and AP (AdaPools) formats.
   *
   * Evaluated as:
   * - missing prop if no extended metadata url is found
   * - `undefined` if a network error has occurred
   * - `null` if no extended metadata was found
   */
  ext?: ExtendedStakePoolMetadata | null | undefined;
}

export type StakePoolMetadata = Cip6MetadataFields &
  APMetadataFields &
  StakePoolMainMetadataFields &
  StakePoolExtendedMetadataFields;

export interface PoolParameters {
  id: PoolId;
  rewardAccount: RewardAccount;
  /**
   * Declared pledge quantity.
   */
  pledge: Lovelace;
  /**
   * Fixed stake pool running cost
   */
  cost: Lovelace;
  /**
   * Stake pool margin percentage
   */
  margin: Fraction;
  /**
   * Metadata location and hash
   */
  metadataJson?: PoolMetadataJson;
  /**
   * Metadata content
   */
  metadata?: StakePoolMetadata;
  /**
   * Stake pool relays
   */
  relays: Relay[];

  owners: RewardAccount[];
  vrf: VrfVkHex;
}
