import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { StakePoolProvider } from '@cardano-sdk/core';

export const defaultStakePoolProviderPaths: HttpProviderConfigPaths<StakePoolProvider> = {
  queryStakePools: '/search'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 */
export const stakePoolHttpProvider = (baseUrl: string, paths = defaultStakePoolProviderPaths): StakePoolProvider =>
  createHttpProvider<StakePoolProvider>({
    baseUrl,
    paths
  });
