import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { NetworkInfoProvider } from '@cardano-sdk/core';

export const defaultNetworkInfoProviderPaths: HttpProviderConfigPaths<NetworkInfoProvider> = {
  networkInfo: '/network'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 */
export const networkInfoHttpProvider = (
  baseUrl: string,
  paths = defaultNetworkInfoProviderPaths
): NetworkInfoProvider =>
  createHttpProvider<NetworkInfoProvider>({
    baseUrl,
    paths
  });
