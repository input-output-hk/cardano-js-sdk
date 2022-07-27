import { CreateHttpProviderConfig, HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { NetworkInfoProvider } from '@cardano-sdk/core';

/**
 * The NetworkInfoProvider endpoint paths.
 */
const paths: HttpProviderConfigPaths<NetworkInfoProvider> = {
  currentWalletProtocolParameters: '/current-wallet-protocol-parameters',
  genesisParameters: '/genesis-parameters',
  healthCheck: '/health',
  ledgerTip: '/ledger-tip',
  lovelaceSupply: '/lovelace-supply',
  stake: '/stake',
  timeSettings: '/time-settings'
};

/**
 * Connect to a Cardano Services HttpServer instance with the service available
 *
 * @param config The configuration object fot the NetworkInfoProvider Provider.
 */
export const networkInfoHttpProvider = (config: CreateHttpProviderConfig<NetworkInfoProvider>): NetworkInfoProvider =>
  createHttpProvider<NetworkInfoProvider>({
    ...config,
    paths
  });
