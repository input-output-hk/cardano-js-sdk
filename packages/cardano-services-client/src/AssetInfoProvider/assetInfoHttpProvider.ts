import { apiVersion } from '../version.js';
import { createHttpProvider } from '../HttpProvider.js';
import type { AssetProvider, HttpProviderConfigPaths } from '@cardano-sdk/core';
import type { CreateHttpProviderConfig } from '../HttpProvider.js';

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
    apiVersion: apiVersion.assetInfo,
    paths,
    serviceSlug: 'asset'
  });
