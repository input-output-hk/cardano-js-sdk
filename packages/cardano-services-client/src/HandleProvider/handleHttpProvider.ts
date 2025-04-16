import { CreateHttpProviderConfig, createHttpProvider } from '../HttpProvider';
import { HandleProvider, handleProviderPaths } from '@cardano-sdk/core';
import { apiVersion } from '../version';

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the HandleProvider.
 */
export const handleHttpProvider = (config: CreateHttpProviderConfig<HandleProvider>): HandleProvider =>
  createHttpProvider<HandleProvider>({
    ...config,
    apiVersion: config.apiVersion || apiVersion.handle,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    modifyData: (method: string | number | symbol, data: any) =>
      method === 'resolveHandles' ? { ...data, check_handle: true } : { ...data },
    paths: handleProviderPaths,
    serviceSlug: 'handle'
  });
