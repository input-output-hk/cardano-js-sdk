import { AxiosAdapter } from 'axios';
import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { StakePoolProvider } from '@cardano-sdk/core';

export const defaultStakePoolProviderPaths: HttpProviderConfigPaths<StakePoolProvider> = {
  healthCheck: '/health',
  queryStakePools: '/search',
  stakePoolStats: '/stats'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 * @param paths  A mapping between provider method names and url paths. Paths have to use /leadingSlash
 * @param adapter This adapter that allows to you to modify the way Axios make requests.
 */
export const stakePoolHttpProvider = (
  baseUrl: string,
  paths = defaultStakePoolProviderPaths,
  adapter?: AxiosAdapter
): StakePoolProvider =>
  createHttpProvider<StakePoolProvider>({
    adapter,
    baseUrl,
    paths
  });
