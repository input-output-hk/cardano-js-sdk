import { AssetProvider } from '@cardano-sdk/core';
import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';

export const defaultAssetProviderPaths: HttpProviderConfigPaths<AssetProvider> = {
  getAsset: '/get-asset'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 */
export const assetInfoHttpProvider = (baseUrl: string, paths = defaultAssetProviderPaths): AssetProvider =>
  createHttpProvider<AssetProvider>({
    baseUrl,
    paths
  });
