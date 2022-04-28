import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { ProviderError, ProviderFailure, UtxoProvider } from '@cardano-sdk/core';

export const defaultUtxoProviderPaths: HttpProviderConfigPaths<UtxoProvider> = {
  healthCheck: '/health',
  utxoByAddresses: '/utxo-by-addresses'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 */
export const utxoHttpProvider = (baseUrl: string, paths = defaultUtxoProviderPaths): UtxoProvider =>
  createHttpProvider<UtxoProvider>({
    baseUrl,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    mapError: (error: any, method) => {
      if (method === 'healthCheck' && !error) {
        return { ok: false };
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths
  });
