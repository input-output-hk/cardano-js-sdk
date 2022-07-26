import { AssetProvider } from '@cardano-sdk/core';
import { AxiosAdapter } from 'axios';
import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';

export const defaultAssetProviderPaths: HttpProviderConfigPaths<AssetProvider> = {
  getAsset: '/get-asset',
  healthCheck: '/health'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 * @param paths A mapping between provider method names and url paths. Paths have to use /leadingSlash
 * @param adapter This adapter that allows to you to modify the way Axios make requests.
 */
export const assetInfoHttpProvider = (
  baseUrl: string,
  paths = defaultAssetProviderPaths,
  adapter?: AxiosAdapter
): AssetProvider =>
  createHttpProvider<AssetProvider>({
    adapter,
    baseUrl,
    paths
  });
