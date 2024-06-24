import { CreateHttpProviderConfig, createHttpProvider } from '../HttpProvider';
import { HttpProviderConfigPaths, ProviderError, ProviderFailure, UtxoProvider } from '@cardano-sdk/core';
import { apiVersion } from '../version';
import { mapHealthCheckError } from '../mapHealthCheckError';

/** The UtxoProvider endpoint paths. */
const paths: HttpProviderConfigPaths<UtxoProvider> = {
  healthCheck: '/health',
  utxoByAddresses: '/utxo-by-addresses'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the Utxo Provider.
 */
export const utxoHttpProvider = (config: CreateHttpProviderConfig<UtxoProvider>): UtxoProvider =>
  createHttpProvider<UtxoProvider>({
    ...config,
    apiVersion: config.apiVersion || apiVersion.utxo,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    mapError: (error: any, method) => {
      if (method === 'healthCheck') {
        return mapHealthCheckError(error);
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths,
    serviceSlug: 'utxo'
  });
