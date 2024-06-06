import { ProviderError, ProviderFailure } from '@cardano-sdk/core';
import { apiVersion } from '../version.js';
import { createHttpProvider } from '../HttpProvider.js';
import type { ChainHistoryProvider, HttpProviderConfigPaths } from '@cardano-sdk/core';
import type { CreateHttpProviderConfig } from '../HttpProvider.js';

/** The ChainHistoryProvider endpoint paths. */
const paths: HttpProviderConfigPaths<ChainHistoryProvider> = {
  blocksByHashes: '/blocks/by-hashes',
  healthCheck: '/health',
  transactionsByAddresses: '/txs/by-addresses',
  transactionsByHashes: '/txs/by-hashes'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the NetworkInfoProvider Provider.
 * @returns {ChainHistoryProvider} ChainHistoryProvider
 */
export const chainHistoryHttpProvider = (
  config: CreateHttpProviderConfig<ChainHistoryProvider>
): ChainHistoryProvider =>
  createHttpProvider<ChainHistoryProvider>({
    ...config,
    apiVersion: apiVersion.chainHistory,
    mapError: (error, method) => {
      if (method === 'healthCheck' && !error) {
        return { ok: false };
      }
      throw new ProviderError(ProviderFailure.Unknown, error);
    },
    paths,
    serviceSlug: 'chain-history'
  });
