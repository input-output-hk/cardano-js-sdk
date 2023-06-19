import { CreateHttpProviderConfig, createHttpProvider } from '../HttpProvider';
import { HandleProvider, handleProviderPaths } from '@cardano-sdk/core';

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the HandleProvider.
 */
export const handleHttpProvider = (config: CreateHttpProviderConfig<HandleProvider>): HandleProvider =>
  createHttpProvider<HandleProvider>({
    ...config,
    paths: handleProviderPaths
  });
