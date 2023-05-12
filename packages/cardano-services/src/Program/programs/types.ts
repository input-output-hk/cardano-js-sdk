import { CommonProgramOptions } from '../options/common';
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
  StakePool = 'stake-pool',
  NetworkInfo = 'network-info',
  TxSubmit = 'tx-submit',
  Utxo = 'utxo',
  ChainHistory = 'chain-history',
  Rewards = 'rewards'
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
  TokenMetadataCacheTtl = 'Token Metadata API cache TTL in minutes',
  TokenMetadataServerUrl = 'Token Metadata API server URL',
  UseTypeOrmStakePoolProvider = 'Enables the TypeORM Stake Pool Provider',
  UseBlockfrost = 'Enables Blockfrost cached data DB',
  UseQueue = 'Enables RabbitMQ',
  PaginationPageSizeLimit = 'Pagination page size limit shared across all providers'
}

export type ProviderServerArgs = CommonProgramOptions &
  PosgresProgramOptions<'DbSync'> &
  OgmiosProgramOptions &
  RabbitMqProgramOptions & {
    allowedOrigins?: string[];
    cardanoNodeConfigPath?: string;
    disableDbCache?: boolean;
    disableStakePoolMetricApy?: boolean;
    healthCheckCacheTtl: number;
    tokenMetadataCacheTTL?: number;
    tokenMetadataServerUrl?: string;
    tokenMetadataRequestTimeout?: number;
    epochPollInterval: number;
    dbCacheTtl: number;
    useBlockfrost?: boolean;
    useQueue?: boolean;
    useTypeormStakePoolProvider?: boolean;
    paginationPageSizeLimit?: number;
    serviceNames: ServiceNames[];
  };
