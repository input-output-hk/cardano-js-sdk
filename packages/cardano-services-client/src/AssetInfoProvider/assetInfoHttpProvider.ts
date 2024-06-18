import { AssetProvider, HttpProviderConfigPaths } from '@cardano-sdk/core';
import { CreateHttpProviderConfig, createHttpProvider } from '../HttpProvider';
import { apiVersion } from '../version';

/** The AssetProvider endpoint paths. */
const paths: HttpProviderConfigPaths<AssetProvider> = {
  getAsset: '/get-asset',
  getAssets: '/get-assets',
  healthCheck: '/health'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the AssetProvider Provider.
 */
export const assetInfoHttpProvider = (config: CreateHttpProviderConfig<AssetProvider>): AssetProvider =>
  createHttpProvider<AssetProvider>({
    ...config,
    apiVersion: config.apiVersion || apiVersion.assetInfo,
    paths,
    serviceSlug: 'asset'
  });
