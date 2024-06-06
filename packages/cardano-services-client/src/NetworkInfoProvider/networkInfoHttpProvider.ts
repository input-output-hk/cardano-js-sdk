import { apiVersion } from '../version.js';
import { createHttpProvider } from '../HttpProvider.js';
import type { CreateHttpProviderConfig } from '../HttpProvider.js';
import type { HttpProviderConfigPaths, NetworkInfoProvider } from '@cardano-sdk/core';

/** The NetworkInfoProvider endpoint paths. */
const paths: HttpProviderConfigPaths<NetworkInfoProvider> = {
  eraSummaries: '/era-summaries',
  genesisParameters: '/genesis-parameters',
  healthCheck: '/health',
  ledgerTip: '/ledger-tip',
  lovelaceSupply: '/lovelace-supply',
  protocolParameters: '/protocol-parameters',
  stake: '/stake'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the NetworkInfoProvider Provider.
 */
export const networkInfoHttpProvider = (config: CreateHttpProviderConfig<NetworkInfoProvider>): NetworkInfoProvider =>
  createHttpProvider<NetworkInfoProvider>({
    ...config,
    apiVersion: apiVersion.networkInfo,
    paths,
    serviceSlug: 'network-info'
  });
