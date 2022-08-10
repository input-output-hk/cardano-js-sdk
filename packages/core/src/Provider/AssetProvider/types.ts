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

export interface AssetProvider extends Provider {
  /**
   * @param id asset ID (concatenated hex values of policyId + assetName)
   * @throws ProviderError
   */
  getAsset: (args: GetAssetArgs) => Promise<Asset.AssetInfo>;
}
