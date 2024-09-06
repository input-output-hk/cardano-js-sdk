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
const argParser = (impl: string) => ProviderImplementation[impl.toUpperCase() as keyof typeof ProviderImplementation];
export const providerSelectionOptions = [
  newOption(
    '--asset-provider <implementation>',
    ProviderImplementationDescription,
    'ASSET_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  )
    .conflicts('useTypeormAssetProvider')
    .choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC, ProviderImplementation.TYPEORM]),
  newOption(
    '--stake-pool-provider <implementation>',
    ProviderImplementationDescription,
    'STAKE_POOL_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  )
    .conflicts('useTypeormStakePoolProvider')
    .choices([ProviderImplementation.DBSYNC, ProviderImplementation.TYPEORM]),
  newOption(
    '--utxo-provider <implementation>',
    ProviderImplementationDescription,
    'UTXO_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC]),
  newOption(
    '--chain-history-provider <implementation>',
    ProviderImplementationDescription,
    'CHAIN_HISTORY_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC]),
  newOption(
    '--rewards-provider <implementation>',
    ProviderImplementationDescription,
    'REWARDS_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC]),
  newOption(
    '--network-info-provider <implementation>',
    ProviderImplementationDescription,
    'NETWORK_INFO_PROVIDER',
    argParser,
    ProviderImplementation.DBSYNC
  ).choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.DBSYNC]),
  newOption(
    '--tx-submit-provider <implementation>',
    ProviderImplementationDescription,
    'TX_SUBMIT_PROVIDER',
    argParser,
    ProviderImplementation.SUBMIT_NODE
  )
    .conflicts('useSubmitApi')
    .choices([ProviderImplementation.BLOCKFROST, ProviderImplementation.SUBMIT_API, ProviderImplementation.SUBMIT_NODE])
];
