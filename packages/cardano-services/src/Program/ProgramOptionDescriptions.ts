import { CommonOptionDescriptions } from '../ProgramsCommon';

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
  UseQueue = 'Enables RabbitMQ'
}

export type ProgramOptionDescriptions = CommonOptionDescriptions | HttpServerOptionDescriptions;
export const ProgramOptionDescriptions = {
  ...CommonOptionDescriptions,
  ...HttpServerOptionDescriptions
};
