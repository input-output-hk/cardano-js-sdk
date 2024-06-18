import { CreateHttpProviderConfig, createHttpProvider } from '../HttpProvider';
import { HttpProviderConfigPaths, ProviderError, ProviderFailure, RewardsProvider } from '@cardano-sdk/core';
import { apiVersion } from '../version';
import { mapHealthCheckError } from '../mapHealthCheckError';

/** The RewardsProvider endpoint paths. */
const paths: HttpProviderConfigPaths<RewardsProvider> = {
  healthCheck: '/health',
  rewardAccountBalance: '/account-balance',
  rewardsHistory: '/history'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the RewardsProvider Provider.
 */
export const rewardsHttpProvider = (config: CreateHttpProviderConfig<RewardsProvider>): RewardsProvider =>
  createHttpProvider<RewardsProvider>({
    ...config,
    apiVersion: config.apiVersion || apiVersion.rewards,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    mapError: (error: any, method) => {
      if (method === 'healthCheck') {
        return mapHealthCheckError(error);
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths,
    serviceSlug: 'rewards'
  });
