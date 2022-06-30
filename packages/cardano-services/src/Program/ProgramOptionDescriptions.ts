import { CommonOptionDescriptions } from '../ProgramsCommon';

enum HttpServerOptionDescriptions {
  ApiUrl = 'API URL',
  DbConnection = 'DB Connection',
  MetricsEnabled = 'Enable Prometheus Metrics',
  OgmiosUrl = 'Ogmios URL',
  RabbitMQUrl = 'RabbitMQ URL',
  UseQueue = 'Enables RabbitMQ',
  CardanoNodeConfigPath = 'Cardano node config path',
  DbQueriesCacheTtl = 'Db queries cache TTL in minutes between 1 and 2880',
  DbPollInterval = 'Db poll interval',
  ServiceDiscoveryBackoffFactor = 'Exponential backoff factor for service discovery',
  ServiceDiscoverBackoffTimeout = 'Exponential backoff max timeout for service discovery'
}

export type ProgramOptionDescriptions = CommonOptionDescriptions | HttpServerOptionDescriptions;
export const ProgramOptionDescriptions = { ...CommonOptionDescriptions, ...HttpServerOptionDescriptions };
