import { CommonOptionDescriptions } from '../ProgramsCommon';

enum HttpServerOptionDescriptions {
  ApiUrl = 'API URL',
  CardanoNodeConfigPath = 'Cardano node config path',
  DbConnection = 'DB Connection string',
  EpochPollInterval = 'Epoch poll interval',
  MetricsEnabled = 'Enable Prometheus Metrics',
  OgmiosUrl = 'Ogmios URL',
  PostgresSrvArgs = 'Postgres SRV service name, db, user and password',
  RabbitMQUrl = 'RabbitMQ URL',
  TokenMetadataCacheTtl = 'Token Metadata API cache TTL in minutes',
  TokenMetadataServerUrl = 'Token Metadata API server URL',
  UseQueue = 'Enables RabbitMQ'
}

export type ProgramOptionDescriptions = CommonOptionDescriptions | HttpServerOptionDescriptions;
export const ProgramOptionDescriptions = {
  ...CommonOptionDescriptions,
  ...HttpServerOptionDescriptions
};
