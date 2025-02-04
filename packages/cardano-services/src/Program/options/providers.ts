import { newOption } from './util';

export enum ProviderImplementation {
  TYPEORM = 'typeorm',
  BLOCKFROST = 'blockfrost',
  DBSYNC = 'dbsync',
  // Below ones are specific to TxSubmitProvider
  SUBMIT_NODE = 'submit-node',
  SUBMIT_API = 'submit-api'
}

export type ProviderImplementations = {
  assetProvider?: ProviderImplementation;
  rewardsProvider?: ProviderImplementation;
  networkInfoProvider?: ProviderImplementation;
  utxoProvider?: ProviderImplementation;
  txSubmitProvider?: ProviderImplementation;
  chainHistoryProvider?: ProviderImplementation;
  stakePoolProvider?: ProviderImplementation;
};
export const ProviderImplementationDescription = 'Select one of the available provider implementations';
export const argParser = (impl: string) => ProviderImplementation[impl.toUpperCase() as keyof typeof ProviderImplementation];
export const providerSelectionOptions = [
  newOption(
    '--asset-provider <assetProvider>',
    ProviderImplementationDescription,
    'ASSET_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC, ProviderImplementation.TYPEORM]),
  newOption(
    '--stake-pool-provider <stakePoolProvider>',
    ProviderImplementationDescription,
    'STAKE_POOL_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.DBSYNC, ProviderImplementation.TYPEORM]),
  newOption(
    '--utxo-provider <utxoProvider>',
    ProviderImplementationDescription,
    'UTXO_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC]),
  newOption(
    '--chain-history-provider <chainHistoryProvider>',
    ProviderImplementationDescription,
    'CHAIN_HISTORY_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC]),
  newOption(
    '--rewards-provider <rewardsProvider>',
    ProviderImplementationDescription,
    'REWARDS_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC]),
  newOption(
    '--network-info-provider <networkInfoProvider>',
    ProviderImplementationDescription,
    'NETWORK_INFO_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC]),
  newOption(
    '--tx-submit-provider <txSubmitProvider>',
    ProviderImplementationDescription,
    'TX_SUBMIT_PROVIDER',
    argParser,
    ProviderImplementation.SUBMIT_NODE
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.SUBMIT_API, ProviderImplementation.SUBMIT_NODE])
];
