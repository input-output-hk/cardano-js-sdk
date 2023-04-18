import { Asset, Cardano, Provider } from '../..';

interface AssetExtraData {
  nftMetadata?: boolean;
  tokenMetadata?: boolean;
  history?: boolean;
}

export interface GetAssetArgs {
  assetId: Cardano.AssetId;
  extraData?: AssetExtraData;
}

export interface GetAssetsArgs {
  assetIds: Cardano.AssetId[];
  extraData?: Omit<AssetExtraData, 'history'>;
}

export interface AssetProvider extends Provider {
  /**
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
