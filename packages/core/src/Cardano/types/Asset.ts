import { TransactionId } from './Transaction';

export type AssetId = string;
export type PolicyId = string;
export type AssetFingerprint = string;

/**
 * Either on-chain or off-chain asset metadata
 *
 * CIP-0031
 * https://github.com/cardano-foundation/CIPs/pull/137
 */
export interface AssetMetadata {
  /**
   * Asset name
   */
  name?: string;
  /**
   * when present, field and overrides default ticker which is the asset name
   */
  ticker?: string;
  /**
   * MUST be either https, ipfs, or data.  logo MUST be a browser supported image format.
   */
  logo?: string;
  /**
   * MUST be either https, ipfs, or data.  logo MUST be a browser supported image format.
   */
  icon?: string;
  /**
   * MUST be either https, ipfs, or data.  logo MUST be a browser supported image format.
   */
  image?: string;
  /**
   * https only url that refers to metadata stored offchain.
   * The URL SHOULD use the project domain and
   * MUST return authenticity metadata in either html or json format (see below)
   */
  url?: string;
  /**
   * additional description that defines the usage of the token
   */
  desc?: string;
  /**
   * how many decimal places should the token support? For ADA, this would be 6 e.g. 1 ADA is 10^6 Lovelace
   */
  decimals?: number;
  /**
   * https only url that holds the metadata in the onchain format.
   * The URL SHOULD use the project domain and MUST return the token metadata as described above
   */
  ref?: string;
  /**
   * when not specified, version will default to `1.0`
   */
  version?: '1.0';
  /**
   * Possibly: 'logo-[size]' or 'icon-[size]' where size is one of 16, 32, 64, 96, 128
   */
  [key: string]: unknown;
}

export enum AssetProvisioning {
  Mint = 'MINT',
  Burn = 'BURN'
}

export interface AssetMintOrBurn {
  transactionId: TransactionId;
  quantity: bigint;
  action: AssetProvisioning;
}

export interface Asset {
  assetId: AssetId;
  policyId: PolicyId;
  name: string;
  fingerprint: AssetFingerprint;
  quantity: bigint;
  history: AssetMintOrBurn[];
  metadata?: AssetMetadata;
}
