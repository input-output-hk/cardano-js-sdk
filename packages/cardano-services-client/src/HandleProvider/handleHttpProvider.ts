import { apiVersion } from '../version.js';
import { createHttpProvider } from '../HttpProvider.js';
import { handleProviderPaths } from '@cardano-sdk/core';
import type { CreateHttpProviderConfig } from '../HttpProvider.js';
import type { HandleProvider } from '@cardano-sdk/core';

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the HandleProvider.
 */
export const handleHttpProvider = (config: CreateHttpProviderConfig<HandleProvider>): HandleProvider =>
  createHttpProvider<HandleProvider>({
    ...config,
    apiVersion: apiVersion.handle,
    paths: handleProviderPaths,
    serviceSlug: 'handle'
  });
