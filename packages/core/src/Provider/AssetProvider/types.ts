import type { Asset, Cardano, Provider } from '../../index.js';

export interface AssetsExtraData {
  nftMetadata?: boolean;
  tokenMetadata?: boolean;
}

export interface GetAssetArgs {
  assetId: Cardano.AssetId;
  extraData?: AssetsExtraData;
}

export interface GetAssetsArgs {
  assetIds: Cardano.AssetId[];
  extraData?: AssetsExtraData;
}

export interface AssetProvider extends Provider {
  /**
   * @param assetId asset ID (concatenated hex values of policyId + assetName)
   * @param extraData optional extra data to be provided - nftMetadata or tokenMetadata
   * @throws ProviderError
   */
  getAsset: (args: GetAssetArgs) => Promise<Asset.AssetInfo>;

  /**
   * @param assetIds asset IDs (concatenated hex values of policyId + assetName)
   * @param extraData optional extra data to be provided - nftMetadata or tokenMetadata
   * @throws ProviderError
   */
  getAssets: (args: GetAssetsArgs) => Promise<Asset.AssetInfo[]>;
}
