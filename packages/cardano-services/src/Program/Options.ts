import { LogLevel } from 'bunyan';

export enum CommonOptionDescriptions {
  DbCacheTtl = 'Cache TTL in minutes between 1 and 2880, an option for database related operations',
  LoggerMinSeverity = 'Log level',
  OgmiosSrvServiceName = 'Ogmios SRV service name',
  OgmiosUrl = 'Ogmios URL',
  RabbitMQSrvServiceName = 'RabbitMQ SRV service name',
  RabbitMQUrl = 'RabbitMQ URL',
  ServiceDiscoveryBackoffFactor = 'Exponential backoff factor for service discovery',
  ServiceDiscoveryTimeout = 'Timeout for service discovery attempts'
}

enum HttpServerOptionDescriptions {
  ApiUrl = 'API URL',
  CardanoNodeConfigPath = 'Cardano node config path',
  EpochPollInterval = 'Epoch poll interval',
  EnableMetrics = 'Enable Prometheus Metrics',
  OgmiosUrl = 'Ogmios URL',
  PostgresConnectionString = 'PostgreSQL Connection string',
  PostgresSrvServiceName = 'PostgreSQL SRV service name when using service discovery',
  PostgresDb = 'PostgreSQL database name',
  PostgresDbFile = 'PostgreSQL database name file path',
  PostgresUser = 'PostgreSQL user',
  PostgresUserFile = 'PostgreSQL user file path',
  PostgresPassword = 'PostgreSQL password',
  PostgresPasswordFile = 'PostgreSQL password file path',
  PostgresSslCaFile = 'PostgreSQL SSL CA file path',
  PostgresHost = 'PostgreSQL host',
  PostgresPort = 'PostgreSQL port',
  PostgresServiceDiscoveryArgs = 'Postgres SRV service name, db, user and password',
  RabbitMQUrl = 'RabbitMQ URL',
  TokenMetadataCacheTtl = 'Token Metadata API cache TTL in minutes',
  TokenMetadataServerUrl = 'Token Metadata API server URL',
  UseQueue = 'Enables RabbitMQ',
  PaginationPageSizeLimit = 'Pagination page size limit shared across all providers'
}

export enum TxWorkerOptionDescriptions {
  Parallel = 'Parallel mode',
  ParallelTxs = 'Parallel transactions',
  PollingCycle = 'Polling cycle'
}

export type ProgramOptionDescriptions = CommonOptionDescriptions | HttpServerOptionDescriptions;

export const ProgramOptionDescriptions = {
  ...CommonOptionDescriptions,
  ...HttpServerOptionDescriptions
};

/**
 * Common options for programs:
 * - HTTP server
 * - RabbitMQ worker
 */
export interface CommonProgramOptions {
  loggerMinSeverity?: LogLevel;
  ogmiosUrl?: URL;
  rabbitmqUrl?: URL;
  ogmiosSrvServiceName?: string;
  rabbitmqSrvServiceName?: string;
  serviceDiscoveryBackoffFactor?: number;
  serviceDiscoveryTimeout?: number;
}
