import { CreateHttpProviderConfig, HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { HandleProvider } from '@cardano-sdk/core';

/**
 * The HandleProvider endpoint paths.
 */
const paths: HttpProviderConfigPaths<HandleProvider> = {
  healthCheck: '/health',
  resolveHandles: '/resolve'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the HandleProvider.
 */
export const handleHttpProvider = (config: CreateHttpProviderConfig<HandleProvider>): HandleProvider =>
  createHttpProvider<HandleProvider>({
    ...config,
    paths
  });
