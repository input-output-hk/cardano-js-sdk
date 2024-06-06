import { apiVersion } from '../version.js';
import { createHttpProvider } from '../HttpProvider.js';
import type { CreateHttpProviderConfig } from '../HttpProvider.js';
import type { HttpProviderConfigPaths, StakePoolProvider } from '@cardano-sdk/core';

/** The StakePoolProvider endpoint paths. */
const paths: HttpProviderConfigPaths<StakePoolProvider> = {
  healthCheck: '/health',
  queryStakePools: '/search',
  stakePoolStats: '/stats'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the StakePool Provider.
 */
export const stakePoolHttpProvider = (config: CreateHttpProviderConfig<StakePoolProvider>): StakePoolProvider =>
  createHttpProvider<StakePoolProvider>({
    ...config,
    apiVersion: apiVersion.stakePool,
    paths,
    serviceSlug: 'stake-pool'
  });
