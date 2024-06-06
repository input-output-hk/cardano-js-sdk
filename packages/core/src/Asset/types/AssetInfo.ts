import type { AssetFingerprint, AssetId, AssetName, PolicyId, TransactionId } from '../../Cardano/index.js';
import type { NftMetadata } from '../NftMetadata/index.js';
import type { TokenMetadata } from './TokenMetadata.js';

export interface AssetMintOrBurn {
  transactionId: TransactionId;
  /** Positive = mint Negative = burn */
  quantity: bigint;
}

export interface AssetInfo {
  assetId: AssetId;
  policyId: PolicyId;
  name: AssetName;
  fingerprint: AssetFingerprint;
  /**
   * @deprecated Use `supply` instead
   */
  quantity: bigint;
  supply: bigint;
  /** CIP-0035. `undefined` if not loaded, `null` if no metadata found */
  tokenMetadata?: TokenMetadata | null;
  /** CIP-0025. `undefined` if not loaded, `null` if no metadata found */
  nftMetadata?: NftMetadata | null;
}
