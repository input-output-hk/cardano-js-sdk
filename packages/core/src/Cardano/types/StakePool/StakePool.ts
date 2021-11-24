import { ExtendedStakePoolMetadata } from './ExtendedStakePoolMetadata';
import { Hash16, Lovelace, PoolParameters, TransactionId } from '..';
import { PoolIdHex } from './primitives';

/**
 * Within range [0; 1]
 */
export type Percent = number;

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
  extVkey?: Hash16; // TODO: Review: need to find an example of this to verify type and length
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

export interface StakePoolMetricsStake {
  live: Lovelace;
  active: Lovelace;
}

export interface StakePoolMetricsSize {
  live: Percent;
  active: Percent;
}
export interface StakePoolMetrics {
  /**
   * Total blocks created by the pool
   */
  blocksCreated: number;
  livePledge: Lovelace;
  /**
   * Stake quantity
   */
  stake: StakePoolMetricsStake;
  /**
   * Percentage of total stake
   */
  size: StakePoolMetricsSize;
  saturation: Percent;
  delegators: number;
}

export interface StakePoolTransactions {
  registration: TransactionId[];
  retirement: TransactionId[];
}

export enum StakePoolStatus {
  Active = 'active',
  Retired = 'retired',
  Retiring = 'retiring'
}

export interface StakePool extends PoolParameters {
  /**
   * Stake pool ID as a hex string
   */
  hexId: PoolIdHex;
  /**
   * Stake pool metrics
   */
  metrics: StakePoolMetrics;
  /**
   * Stake pool status
   */
  status: StakePoolStatus;
  /**
   * Transactions provisioning the stake pool
   */
  transactions: StakePoolTransactions;
  /**
   * Metadata content
   */
  metadata?: StakePoolMetadata;
}
