import { Asset, Cardano } from '@cardano-sdk/core';
import { Shutdown } from '@cardano-sdk/util';

/**
 * Cardano.AssetId as an object with `policyId` and `name`
 */
export type AssetPolicyIdAndName = Pick<Asset.AssetInfo, 'name' | 'policyId'>;

/**
 * Service to get CIP-25 NFT metadata for a given asset
 */
export interface NftMetadataService {
  /**
   * Get CIP-25 NFT metadata for a given asset
   *
   * @returns CIP-25 NFT metadata for NFTs, `undefined` for assets that are not NFTs
   */
  getNftMetadata(asset: AssetPolicyIdAndName): Promise<Asset.NftMetadata | undefined>;
}

/**
 * Service to get CIP-38? token metadata for a given subject
 */
export interface TokenMetadataService extends Shutdown {
  /**
   * Get CIP-38? token metadata for a given subject
   *
   * @returns CIP-38? token metadata, `null` if not found
   */
  getTokenMetadata(assetIds: Cardano.AssetId[]): Promise<(Asset.TokenMetadata | null)[]>;
}

export interface MultiAssetModel {
  fingerprint: string;
  id: string;
}

export interface MultiAssetHistoryModel {
  hash: Buffer;
  quantity: string;
}

export interface MultiAssetQuantitiesModel {
  count: string;
  sum: string;
}
