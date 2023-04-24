import { AssetFingerprint, AssetId, AssetName, PolicyId, TransactionId } from '../../Cardano';
import { NftMetadata } from './NftMetadata';
import { TokenMetadata } from './TokenMetadata';

export interface AssetMintOrBurn {
  transactionId: TransactionId;
  /**
   * Positive = mint
   * Negative = burn
   */
  quantity: bigint;
}

export interface AssetInfo {
  assetId: AssetId;
  policyId: PolicyId;
  name: AssetName;
  fingerprint: AssetFingerprint;
  supply: bigint;
  mintOrBurnCount: number;
  /**
   * Sorted by slot
   */
  history?: AssetMintOrBurn[];
  /**
   * CIP-0035. `undefined` if not loaded, `null` if no metadata found
   */
  tokenMetadata?: TokenMetadata | null;
  /**
   * CIP-0025. `undefined` if not loaded, `null` if no metadata found
   */
  nftMetadata?: NftMetadata | null;
}
