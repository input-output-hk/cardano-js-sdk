import { AxiosAdapter } from 'axios';
import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { ProviderError, ProviderFailure, RewardsProvider } from '@cardano-sdk/core';
import { mapHealthCheckError } from '../mapHealthCheckError';

export const defaultRewardProviderPaths: HttpProviderConfigPaths<RewardsProvider> = {
  healthCheck: '/health',
  rewardAccountBalance: '/account-balance',
  rewardsHistory: '/history'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 * @param paths  A mapping between provider method names and url paths. Paths have to use /leadingSlash
 * @param adapter This adapter that allows to you to modify the way Axios make requests.
 */
export const rewardsHttpProvider = (
  baseUrl: string,
  paths = defaultRewardProviderPaths,
  adapter?: AxiosAdapter
): RewardsProvider =>
  createHttpProvider<RewardsProvider>({
    adapter,
    baseUrl,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    mapError: (error: any, method) => {
      if (method === 'healthCheck') {
        return mapHealthCheckError(error);
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths
  });
