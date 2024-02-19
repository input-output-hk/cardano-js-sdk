import {
  CommonProgramOptions,
  OgmiosProgramOptions,
  PosgresProgramOptions,
  StakePoolMetadataProgramOptions
} from '../options';
import { HandlePolicyIdsProgramOptions } from '../options/policyIds';
import { Milliseconds, Seconds } from '@cardano-sdk/core';
import { defaultJobOptions } from '@cardano-sdk/projection-typeorm';

/** cardano-services programs */
export enum Programs {
  BlockfrostWorker = 'Blockfrost worker',
  ProviderServer = 'Provider server',
  Projector = 'Projector'
}

/** Used as mount segments, so must be URL-friendly */
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

export const METADATA_JOB_RETRY_DELAY_DEFAULT = defaultJobOptions.retryDelay;
export const POOLS_METRICS_INTERVAL_DEFAULT = 1000;
export const POOLS_METRICS_OUTDATED_INTERVAL_DEFAULT = 100;

export enum ProjectorOptionDescriptions {
  BlocksBufferLength = 'Chain sync event (blocks) buffer length',
  DropSchema = 'Drop and recreate database schema to project from origin',
  DryRun = 'Initialize the projection, but do not start it',
  ExitAtBlockNo = 'Exit after processing this block. Intended for benchmark testing',
  MetadataJobRetryDelay = 'Retry delay for metadata fetch job in seconds',
  PoolsMetricsInterval = 'Interval in number of blocks between two stake pools metrics jobs to update all metrics',
  PoolsMetricsOutdatedInterval = 'Interval in number of blocks between two stake pools metrics jobs to update only outdated metrics',
  Synchronize = 'Synchronize the schema from the models'
}

export enum ProviderServerOptionDescriptions {
  AllowedOrigins = 'List of allowed CORS origins separated by comma',
  AssetCacheTtl = 'Asset info and NFT Metadata cache TTL in seconds (600 by default)',
  CardanoNodeConfigPath = 'Cardano node config path',
  DbCacheTtl = 'Cache TTL in seconds between 60 and 172800 (two days), an option for database related operations',
  DisableDbCache = 'Disable DB cache',
  DisableStakePoolMetricApy = 'Omit this metric for improved query performance',
  EpochPollInterval = 'Epoch poll interval',
  HandleProviderServerUrl = 'URL for the Handle provider server',
  HealthCheckCacheTtl = 'Health check cache TTL in seconds between 1 and 10',
  PaginationPageSizeLimit = 'Pagination page size limit shared across all providers',
  SubmitApiUrl = 'cardano-submit-api URL',
  TokenMetadataCacheTtl = 'Token Metadata API cache TTL in seconds',
  TokenMetadataRequestTimeout = 'Token Metadata request timeout in milliseconds',
  TokenMetadataServerUrl = 'Token Metadata API server URL',
  UseTypeOrmStakePoolProvider = 'Enables the TypeORM Stake Pool Provider',
  UseBlockfrost = 'Enables Blockfrost cached data DB',
  UseKoraLabsProvider = 'Use the KoraLabs handle provider',
  UseSubmitApi = 'Use cardano-submit-api provider',
  UseTypeormAssetProvider = 'Use the TypeORM Asset Provider (default is db-sync)',
  SubmitValidateHandles = 'Validate handle resolutions before submitting transactions. Requires handle provider options (USE_KORA_LABS or POSTGRES options with HANDLE suffix).'
}

export type ProviderServerArgs = CommonProgramOptions &
  PosgresProgramOptions<'DbSync'> &
  PosgresProgramOptions<'Handle'> &
  PosgresProgramOptions<'StakePool'> &
  PosgresProgramOptions<'Asset'> &
  OgmiosProgramOptions &
  HandlePolicyIdsProgramOptions &
  StakePoolMetadataProgramOptions & {
    allowedOrigins?: string[];
    assetCacheTTL?: Seconds;
    cardanoNodeConfigPath?: string;
    dbCacheTtl: Seconds | 0;
    disableDbCache?: boolean;
    disableStakePoolMetricApy?: boolean;
    epochPollInterval: number;
    handleProviderServerUrl?: string;
    healthCheckCacheTtl: Seconds;
    paginationPageSizeLimit?: number;
    serviceNames: ServiceNames[];
    submitApiUrl?: URL;
    submitValidateHandles?: boolean;
    tokenMetadataCacheTTL?: Seconds;
    tokenMetadataServerUrl?: string;
    tokenMetadataRequestTimeout?: Milliseconds;
    useBlockfrost?: boolean;
    useKoraLabs?: boolean;
    useSubmitApi?: boolean;
    useTypeormAssetProvider?: boolean;
    useTypeormStakePoolProvider?: boolean;
  };
