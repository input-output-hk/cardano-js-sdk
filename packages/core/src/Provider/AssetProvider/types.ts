import { Asset, Cardano, Provider } from '../..';

export interface AssetsExtraData {
  nftMetadata?: boolean;
  tokenMetadata?: boolean;
}

/**
 * @deprecated Use `AssetsExtraData` with `getAssets` instead
 */
export interface AssetExtraData extends AssetsExtraData {
  history?: boolean;
}

/**
 * @deprecated Use `GetAssetsArgs` with `getAssets` instead
 */
export interface GetAssetArgs {
  assetId: Cardano.AssetId;
  extraData?: AssetExtraData;
}

export interface GetAssetsArgs {
  assetIds: Cardano.AssetId[];
  extraData?: AssetsExtraData;
}

export interface AssetProvider extends Provider {
  /**
   * @deprecated Use `getAssets` instead
   * @param assetId asset ID (concatenated hex values of policyId + assetName)
   * @param extraData optional extra data to be provided - nftMetadata, tokenMetadata or history
   * @throws ProviderError
   */
  getAsset: (args: GetAssetArgs) => Promise<Asset.AssetInfo>;

  /**
   * @param assetIds asset IDs (concatenated hex values of policyId + assetName)
   * @param extraData optional extra data to be provided - nftMetadata, tokenMetadata or history
   * @throws ProviderError
   */
  getAssets: (args: GetAssetsArgs) => Promise<Asset.AssetInfo[]>;
}
