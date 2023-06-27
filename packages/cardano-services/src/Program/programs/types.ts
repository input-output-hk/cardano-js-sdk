import { CommonProgramOptions } from '../options/common';
import { HandlePolicyIdsProgramOptions } from '../options/policyIds';
import { Milliseconds, Seconds } from '@cardano-sdk/core';
import { OgmiosProgramOptions } from '../options/ogmios';
import { PosgresProgramOptions } from '../options/postgres';
import { RabbitMqProgramOptions } from '../options/rabbitMq';

/**
 * cardano-services programs
 */
export enum Programs {
  BlockfrostWorker = 'Blockfrost worker',
  ProviderServer = 'Provider server',
  RabbitmqWorker = 'RabbitMQ worker',
  Projector = 'Projector'
}

/**
 * Used as mount segments, so must be URL-friendly
 *
 */
export enum ServiceNames {
  Asset = 'asset',
  ChainHistory = 'chain-history',
  Handle = 'handle',
  NetworkInfo = 'network-info',
  Rewards = 'rewards',
  StakePool = 'stake-pool',
  TxSubmit = 'tx-submit',
  Utxo = 'utxo'
}

export const POOLS_METRICS_INTERVAL_DEFAULT = 1000;

export enum ProjectorOptionDescriptions {
  DropSchema = 'Drop and recreate database schema to project from origin',
  DryRun = 'Initialize the projection, but do not start it',
  PoolsMetricsInterval = 'Interval between two stake pools metrics jobs in number of blocks',
  Synchronize = 'Synchronize the schema from the models'
}

export enum ProviderServerOptionDescriptions {
  CardanoNodeConfigPath = 'Cardano node config path',
  DbCacheTtl = 'Cache TTL in seconds between 60 and 172800 (two days), an option for database related operations',
  AllowedOrigins = 'List of allowed CORS origins separated by comma',
  DisableDbCache = 'Disable DB cache',
  DisableStakePoolMetricApy = 'Omit this metric for improved query performance',
  EpochPollInterval = 'Epoch poll interval',
  AssetCacheTtl = 'Asset info and NFT Metadata cache TTL in seconds (600 by default)',
  TokenMetadataCacheTtl = 'Token Metadata API cache TTL in seconds',
  TokenMetadataServerUrl = 'Token Metadata API server URL',
  UseTypeOrmStakePoolProvider = 'Enables the TypeORM Stake Pool Provider',
  UseBlockfrost = 'Enables Blockfrost cached data DB',
  UseQueue = 'Enables RabbitMQ',
  PaginationPageSizeLimit = 'Pagination page size limit shared across all providers',
  HandleProviderServerUrl = 'URL for the Handle provider server'
}

export type ProviderServerArgs = CommonProgramOptions &
  PosgresProgramOptions<'DbSync'> &
  PosgresProgramOptions<'Handle'> &
  PosgresProgramOptions<'StakePool'> &
  OgmiosProgramOptions &
  HandlePolicyIdsProgramOptions &
  RabbitMqProgramOptions & {
    allowedOrigins?: string[];
    cardanoNodeConfigPath?: string;
    disableDbCache?: boolean;
    disableStakePoolMetricApy?: boolean;
    healthCheckCacheTtl: Seconds;
    assetCacheTTL?: Seconds;
    tokenMetadataCacheTTL?: Seconds;
    tokenMetadataServerUrl?: string;
    tokenMetadataRequestTimeout?: Milliseconds;
    epochPollInterval: number;
    dbCacheTtl: Seconds | 0;
    useBlockfrost?: boolean;
    useQueue?: boolean;
    useTypeormStakePoolProvider?: boolean;
    paginationPageSizeLimit?: number;
    serviceNames: ServiceNames[];
    handleProviderServerUrl: string;
  };
