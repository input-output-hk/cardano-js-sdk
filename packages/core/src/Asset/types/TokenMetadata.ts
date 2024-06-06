import type { Cardano } from '../../index.js';

export interface TokenMetadataSizedIcon {
  /** Most likely one of 16, 32, 64, 96, 128 icons are assumed to be square */
  size: number;
  /** MUST be either https, ipfs, or data.  icon MUST be a browser supported image format. */
  icon: string;
}

/** Either on-chain or off-chain asset metadata CIP-0035 https://github.com/cardano-foundation/CIPs/pull/137 */
export interface TokenMetadata {
  /** Associated asset id (concatenated hex values of policyId + assetName) */
  assetId: Cardano.AssetId;
  /** Asset name */
  name?: string;
  /** when present, field and overrides default ticker which is the asset name */
  ticker?: string;
  /**
   * MUST be either https, ipfs, or data.  icon MUST be a browser supported image format.
   * When implementing the parser, it is recommended to also check 'image' and 'logo'
   * properties for backwards compatibility.
   */
  icon?: string;
  /** allows teams to provide icon in different sizes */
  sizedIcons?: TokenMetadataSizedIcon[];
  /**
   * https only url that refers to metadata stored offchain.
   * The URL SHOULD use the project domain and
   * MUST return authenticity metadata in either html or json format (see below)
   */
  url?: string;
  /** additional description that defines the usage of the token */
  desc?: string;
  /** how many decimal places should the token support? For ADA, this would be 6 e.g. 1 ADA is 10^6 Lovelace */
  decimals?: number;
  /**
   * https only url that holds the metadata in the onchain format.
   * The URL SHOULD use the project domain and MUST return the token metadata as described above
   */
  ref?: string;
  /** when not specified, version will default to `1.0` */
  version?: '1.0';
}
