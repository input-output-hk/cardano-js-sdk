import { PoolId, Hash16, PoolParameters, PoolMetadata } from '@cardano-ogmios/schema';
import { ExtendedStakePoolMetadata } from './ExtendedStakePoolMetadata';
import { Ogmios } from '../../';

/**
 * Within range [0; 1]
 */
export type Percent = number;

export type TransactionId = Hash16;

/**
 * https://github.com/cardano-foundation/CIPs/blob/master/CIP-0006/CIP-0006.md#on-chain-referenced-main-metadata-file
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
  extVkey?: Hash16; // Review: is this the correct type alias?
}

export interface StakePoolMetadataFields {
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

export type StakePoolMetadata = StakePoolMetadataFields &
  Cip6MetadataFields & {
    /**
     * Extended metadata defined by CIP-6
     */
    ext?: ExtendedStakePoolMetadata;
  };

export interface StakePoolMetrics {
  /**
   * Total blocks created by the pool
   */
  blocksCreated: number;
  livePledge: Ogmios.Lovelace;
  /**
   * Stake quantity
   */
  stake: {
    live: Ogmios.Lovelace;
    active: Ogmios.Lovelace;
  };
  /**
   * Percentage of total stake
   */
  size: {
    live: Percent;
    active: Percent;
  };
  saturation: Percent;
  delegators: number;
}

// TODO: don't omit pledge when Ogmios.Lovelace becomes bigint
export interface StakePool extends Omit<PoolParameters, 'pledge' | 'metadata'> {
  /**
   * Stake pool ID as a bech32 string
   */
  id: PoolId;
  /**
   * Stake pool ID as a hex string
   */
  hexId: Hash16;
  /**
   * Declared pledge quantity.
   */
  pledge: Ogmios.Lovelace;
  /**
   * Stake pool metrics
   */
  metrics: StakePoolMetrics;
  /**
   * Transactions provisioning the stake pool
   */
  transactions: {
    registration: TransactionId[];
    retirement: TransactionId[];
  };
  metadataJson?: PoolMetadata;
  metadata?: StakePoolMetadata;
}
