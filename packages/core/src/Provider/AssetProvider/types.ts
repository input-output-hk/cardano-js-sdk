import { Asset, Cardano } from '../..';

interface AssetExtraData {
  nftMetadata?: boolean;
  tokenMetadata?: boolean;
  history?: boolean;
}

export interface AssetProvider {
  /**
   * @param id asset ID (concatenated hex values of policyId + assetName)
   * @throws ProviderError
   */
  getAsset: (id: Cardano.AssetId, extraData?: AssetExtraData) => Promise<Asset.AssetInfo>;
}
