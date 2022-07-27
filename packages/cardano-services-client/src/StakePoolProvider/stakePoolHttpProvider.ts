import { CreateHttpProviderConfig, HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { StakePoolProvider } from '@cardano-sdk/core';

/**
 * The StakePoolProvider endpoint paths.
 */
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
    paths
  });
