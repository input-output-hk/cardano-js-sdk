import { CreateHttpProviderConfig, createHttpProvider } from '../HttpProvider';
import { HttpProviderConfigPaths, NetworkInfoProvider } from '@cardano-sdk/core';
import { apiVersion } from '../version';

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
    apiVersion: config.apiVersion || apiVersion.networkInfo,
    paths,
    serviceSlug: 'network-info'
  });
