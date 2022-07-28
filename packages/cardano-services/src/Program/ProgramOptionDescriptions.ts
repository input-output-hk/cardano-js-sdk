import { CommonOptionDescriptions } from '../ProgramsCommon';

enum HttpServerOptionDescriptions {
  ApiUrl = 'API URL',
  CardanoNodeConfigPath = 'Cardano node config path',
  EpochPollInterval = 'Epoch poll interval',
  EnableMetrics = 'Enable Prometheus Metrics',
  OgmiosUrl = 'Ogmios URL',
  PostgresConnectionString = 'Postgres Connection string',
  PostgresSrvServiceName = 'PostgreSQL SRV service name when using service discovery',
  PostgresDb = 'PostgreSQL database name when using service discovery',
  PostgresUser = 'PostgreSQL user when using service discovery',
  PostgresPassword = 'PostgreSQL password when using service discovery',
  PostgresSslCaFile = 'PostgreSQL SSL CA file path',
  // Will be removed once we consolidate entrypoints and validations via Commander.js
  PostgresServiceDiscoveryArgs = 'Postgres SRV service name, db, user and password',
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
