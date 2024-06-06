import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { apiVersion } from '../version.js';
import { createHttpProvider } from '../HttpProvider.js';
import { mapHealthCheckError } from '../mapHealthCheckError.js';
import type { CreateHttpProviderConfig } from '../HttpProvider.js';
import type { HttpProviderConfigPaths, RewardsProvider } from '@cardano-sdk/core';

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
    apiVersion: apiVersion.rewards,
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
