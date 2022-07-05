import { CommonOptionDescriptions } from '../ProgramsCommon';

enum HttpServerOptionDescriptions {
  ApiUrl = 'API URL',
  DbConnection = 'DB Connection string',
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

enum SrvOptionDescriptions {
  OgmiosSrvServiceName = 'Ogmios SRV service name',
  PostgresSrvServiceName = 'Postgres SRV service name',
  RabbitMQSrvServiceName = 'RabbitMQ SRV service name'
}

export type ProgramOptionDescriptions = CommonOptionDescriptions | HttpServerOptionDescriptions | SrvOptionDescriptions;
export const ProgramOptionDescriptions = {
  ...CommonOptionDescriptions,
  ...HttpServerOptionDescriptions,
  ...SrvOptionDescriptions
};
