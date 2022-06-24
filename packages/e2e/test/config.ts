import * as envalid from 'envalid';
import {
  AssetProvider,
  Cardano,
  ChainHistoryProvider,
  NetworkInfoProvider,
  RewardsProvider,
  StakePoolProvider,
  TxSubmitProvider,
  UtxoProvider,
  WalletProvider
} from '@cardano-sdk/core';
import { FaucetProvider } from '../src/FaucetProvider';
import { KeyManagement } from '@cardano-sdk/wallet';
import { LogLevel, createLogger } from 'bunyan';
import { Logger } from 'ts-log';
import {
  assetProviderFactory,
  chainHistoryProviderFactory,
  faucetProviderFactory,
  keyManagementFactory,
  networkInfoProviderFactory,
  rewardsProviderFactory,
  stakePoolProviderFactory,
  txSubmitProviderFactory,
  utxoProviderFactory,
  walletProviderFactory
} from '../src/factories';
import memoize from 'lodash/memoize';

// Validate environemnt variables

const loggerMethodNames = ['debug', 'error', 'fatal', 'info', 'trace', 'warn'] as (keyof Logger)[];

export const env = envalid.cleanEnv(process.env, {
  ASSET_PROVIDER: envalid.str(),
  ASSET_PROVIDER_PPARAMS: envalid.json(),
  CHAIN_HISTORY_PROVIDER: envalid.str(),
  CHAIN_HISTORY_PROVIDER_PARAMS: envalid.json(),
  FAUCET_PROVIDER: envalid.str(),
  FAUCET_PROVIDER_PARAMS: envalid.json(),
  KEY_MANAGEMENT_PARAMS: envalid.json(),
  KEY_MANAGEMENT_PROVIDER: envalid.str(),
  LOGGER_MIN_SEVERITY: envalid.str({ choices: loggerMethodNames as string[], default: 'info' }),
  NETWORK_INFO_PROVIDER: envalid.str(),
  NETWORK_INFO_PROVIDER_PARAMS: envalid.json(),
  POOL_ID_1: envalid.str(),
  POOL_ID_2: envalid.str(),
  REWARDS_PROVIDER: envalid.str(),
  REWARDS_PROVIDER_PARAMS: envalid.json(),
  STAKE_POOL_PROVIDER: envalid.str(),
  STAKE_POOL_PROVIDER_PARAMS: envalid.json(),
  TX_SUBMIT_PROVIDER: envalid.str(),
  TX_SUBMIT_PROVIDER_PARAMS: envalid.json(),
  UTXO_PROVIDER: envalid.str(),
  UTXO_PROVIDER_PARAMS: envalid.json(),
  WALLET_PROVIDER: envalid.str(),
  WALLET_PROVIDER_PARAMS: envalid.json()
});

// Logger
export const logger = createLogger({
  level: env.LOGGER_MIN_SEVERITY as LogLevel,
  name: 'e2e tests'
});

export const poolId1 = Cardano.PoolId(env.POOL_ID_1);
export const poolId2 = Cardano.PoolId(env.POOL_ID_2);

// Instantiate providers

export const faucetProvider: Promise<FaucetProvider> = faucetProviderFactory.create(
  env.FAUCET_PROVIDER,
  env.FAUCET_PROVIDER_PARAMS
);

export const keyAgentById = memoize(async (accountIndex: number) => {
  const params = env.KEY_MANAGEMENT_PARAMS;
  params.accountIndex = accountIndex;
  return keyManagementFactory.create(env.KEY_MANAGEMENT_PROVIDER, params);
});

export const keyAgent: Promise<KeyManagement.AsyncKeyAgent> = (() => keyAgentById(0))();

export const assetProvider: Promise<AssetProvider> = assetProviderFactory.create(
  env.ASSET_PROVIDER,
  env.ASSET_PROVIDER_PPARAMS
);

export const chainHistoryProvider: Promise<ChainHistoryProvider> = chainHistoryProviderFactory.create(
  env.CHAIN_HISTORY_PROVIDER,
  env.CHAIN_HISTORY_PROVIDER_PARAMS
);

export const networkInfoProvider: Promise<NetworkInfoProvider> = networkInfoProviderFactory.create(
  env.NETWORK_INFO_PROVIDER,
  env.NETWORK_INFO_PROVIDER_PARAMS
);

export const rewardsProvider: Promise<RewardsProvider> = rewardsProviderFactory.create(
  env.REWARDS_PROVIDER,
  env.REWARDS_PROVIDER_PARAMS
);

export const txSubmitProvider: Promise<TxSubmitProvider> = txSubmitProviderFactory.create(
  env.TX_SUBMIT_PROVIDER,
  env.TX_SUBMIT_PROVIDER_PARAMS
);

export const utxoProvider: Promise<UtxoProvider> = utxoProviderFactory.create(
  env.UTXO_PROVIDER,
  env.UTXO_PROVIDER_PARAMS
);

export const walletProvider: Promise<WalletProvider> = walletProviderFactory.create(
  env.WALLET_PROVIDER,
  env.WALLET_PROVIDER_PARAMS
);

export const stakePoolProvider: Promise<StakePoolProvider> = stakePoolProviderFactory.create(
  env.STAKE_POOL_PROVIDER,
  env.STAKE_POOL_PROVIDER_PARAMS
);
