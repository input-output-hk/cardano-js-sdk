import { Hash28ByteBase16, OpaqueString, assertIsHexString, typedBech32 } from '../util';
import { InvalidStringError } from '../..';
import { TransactionId } from './Transaction';

export type AssetId = OpaqueString<'AssetId'>;

/**
 * Hex-encoded asset name
 */
export type AssetName = OpaqueString<'AssetName'>;
export const AssetName = (value: string): AssetName => {
  if (value.length > 0) {
    assertIsHexString(value);
    if (value.length > 64) {
      throw new InvalidStringError('too long');
    }
  }
  return value as unknown as AssetName;
};

/**
 * @param {string} value concatenated PolicyId and AssetName
 * @throws InvalidStringError
 */
export const AssetId = (value: string): AssetId => {
  assertIsHexString(value);
  if (value.length > 120) throw new InvalidStringError('too long');
  if (value.length < 56) throw new InvalidStringError('too short');
  return value as unknown as AssetId;
};

/**
 * Hex-encoded policy id
 */
export type PolicyId = Hash28ByteBase16<'PolicyId'>;
export const PolicyId = (value: string): PolicyId => Hash28ByteBase16(value);

/**
 * Fingerprint of a native asset for human comparison
 * See CIP-0014
 */
export type AssetFingerprint = OpaqueString<'AssetFingerprint'>;
export const AssetFingerprint = (value: string): AssetFingerprint => typedBech32(value, 'asset', 32);

export interface TokenMetadataSizedIcon {
  /**
   * Most likely one of 16, 32, 64, 96, 128
   * icons are assumed to be square
   */
  size: number;
  /**
   * MUST be either https, ipfs, or data.  icon MUST be a browser supported image format.
   */
  icon: string;
}

/**
 * Either on-chain or off-chain asset metadata
 *
 * CIP-0035
 * https://github.com/cardano-foundation/CIPs/pull/137
 */
export interface TokenMetadata {
  /**
   * Asset name
   */
  name?: string;
  /**
   * when present, field and overrides default ticker which is the asset name
   */
  ticker?: string;
  /**
   * MUST be either https, ipfs, or data.  icon MUST be a browser supported image format.
   */
  icon?: string;
  /**
   * allows teams to provide icon in different sizes
   */
  sizedIcons?: TokenMetadataSizedIcon[];
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
}

export interface AssetMintOrBurn {
  transactionId: TransactionId;
  /**
   * Positive = mint
   * Negative = burn
   */
  quantity: bigint;
}

export interface Asset {
  assetId: AssetId;
  policyId: PolicyId;
  name: AssetName;
  fingerprint: AssetFingerprint;
  quantity: bigint;
  /**
   * Sorted by slot
   */
  history: AssetMintOrBurn[];
  /**
   * CIP-0035
   */
  metadata?: TokenMetadata;
}
