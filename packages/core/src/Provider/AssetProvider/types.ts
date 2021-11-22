import { Cardano } from '../..';

export interface AssetProvider {
  /**
   * @param id asset ID (concatenated hex values of policyId + assetName)
   * @throws ProviderError
   */
  getAsset: (id: string) => Promise<Cardano.Asset>;
}
