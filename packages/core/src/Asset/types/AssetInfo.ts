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
  quantity: bigint;
  /**
   * Sorted by slot
   */
  history?: AssetMintOrBurn[];
  /**
   * CIP-0035
   */
  tokenMetadata?: TokenMetadata;
  /**
   * CIP-0025
   */
  nftMetadata?: NftMetadata;
}
