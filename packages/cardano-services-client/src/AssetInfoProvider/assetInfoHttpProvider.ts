import { Asset, AssetProvider } from '@cardano-sdk/core';
import {
  CreateHttpProviderConfig,
  HttpProviderConfig,
  HttpProviderConfigPaths,
  createHttpProvider
} from '../HttpProvider';

/**
 * The AssetProvider endpoint paths.
 */
const paths: HttpProviderConfigPaths<AssetProvider> = {
  getAsset: '/get-asset',
  getAssets: '/get-assets',
  healthCheck: '/health'
};

const isAssetInfo = (assetInfo: unknown): assetInfo is Asset.AssetInfo => !!(assetInfo as Asset.AssetInfo)?.assetId;

const transformQuantityToSupply = (assetInfo: Asset.AssetInfo | unknown): Asset.AssetInfo | unknown => {
  if (isAssetInfo(assetInfo) && assetInfo.supply === undefined) {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const { quantity, ...assetInfoReduced } = assetInfo as any;
    return { ...assetInfoReduced, supply: quantity } as Asset.AssetInfo;
  }
  return assetInfo;
};

const responseTransformers: HttpProviderConfig<AssetProvider>['responseTransformers'] = {
  getAsset: (data: unknown): unknown => transformQuantityToSupply(data),
  getAssets: (data: unknown): unknown =>
    Array.isArray(data) ? data.map((assetInfo) => transformQuantityToSupply(assetInfo)) : data
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the AssetProvider Provider.
 */
export const assetInfoHttpProvider = (config: CreateHttpProviderConfig<AssetProvider>): AssetProvider =>
  createHttpProvider<AssetProvider>({
    ...config,
    paths,
    responseTransformers
  });
