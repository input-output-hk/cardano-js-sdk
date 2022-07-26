import { AxiosAdapter } from 'axios';
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
 * @param paths A mapping between provider method names and url paths. Paths have to use /leadingSlash
 * @param adapter This adapter that allows to you to modify the way Axios make requests.
 */
export const networkInfoHttpProvider = (
  baseUrl: string,
  paths = defaultNetworkInfoProviderPaths,
  adapter?: AxiosAdapter
): NetworkInfoProvider =>
  createHttpProvider<NetworkInfoProvider>({
    adapter,
    baseUrl,
    paths
  });
