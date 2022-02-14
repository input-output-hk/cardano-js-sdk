import { Asset, Cardano } from '../..';

export interface AssetProvider {
  /**
   * @param id asset ID (concatenated hex values of policyId + assetName)
   * @throws ProviderError
   */
  getAsset: (id: Cardano.AssetId) => Promise<Asset.AssetInfo>;
}
