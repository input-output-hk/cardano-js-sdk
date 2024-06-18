import { CreateHttpProviderConfig, createHttpProvider } from '../HttpProvider';
import { HttpProviderConfigPaths, StakePoolProvider } from '@cardano-sdk/core';
import { apiVersion } from '../version';

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
    apiVersion: config.apiVersion || apiVersion.stakePool,
    paths,
    serviceSlug: 'stake-pool'
  });
