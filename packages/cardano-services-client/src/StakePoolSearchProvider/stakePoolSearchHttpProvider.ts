import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { StakePoolSearchProvider } from '@cardano-sdk/core';

export const defaultStakePoolSearchProviderPaths: HttpProviderConfigPaths<StakePoolSearchProvider> = {
  queryStakePools: '/search'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 */
export const stakePoolSearchHttpProvider = (
  baseUrl: string,
  paths = defaultStakePoolSearchProviderPaths
): StakePoolSearchProvider =>
  createHttpProvider<StakePoolSearchProvider>({
    baseUrl,
    paths
  });
