import { AxiosAdapter } from 'axios';
import { ChainHistoryProvider, ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';

export const defaultChainHistoryProviderPaths: HttpProviderConfigPaths<ChainHistoryProvider> = {
  blocksByHashes: '/blocks/by-hashes',
  healthCheck: '/health',
  transactionsByAddresses: '/txs/by-addresses',
  transactionsByHashes: '/txs/by-hashes'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param {string} baseUrl server root url, w/o trailing /
 * @param paths A mapping between provider method names and url paths. Paths have to use /leadingSlash
 * @param adapter This adapter that allows to you to modify the way Axios make requests.
 * @returns {ChainHistoryProvider} ChainHistoryProvider
 */
export const chainHistoryHttpProvider = (
  baseUrl: string,
  paths = defaultChainHistoryProviderPaths,
  adapter?: AxiosAdapter
): ChainHistoryProvider =>
  createHttpProvider<ChainHistoryProvider>({
    adapter,
    baseUrl,
    mapError: (error, method) => {
      if (method === 'healthCheck' && !error) {
        return { ok: false };
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths
  });
