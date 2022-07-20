import { HttpProviderConfigPaths, createHttpProvider } from '../HttpProvider';
import { NetworkInfoProvider } from '@cardano-sdk/core';

export const defaultNetworkInfoProviderPaths: HttpProviderConfigPaths<NetworkInfoProvider> = {
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
 * @param {string} baseUrl server root url, w/o trailing /
 */
export const networkInfoHttpProvider = (
  baseUrl: string,
  paths = defaultNetworkInfoProviderPaths
): NetworkInfoProvider =>
  createHttpProvider<NetworkInfoProvider>({
    baseUrl,
    paths
  });
