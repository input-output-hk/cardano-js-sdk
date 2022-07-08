import { CommonOptionDescriptions } from '../ProgramsCommon';

enum HttpServerOptionDescriptions {
  ApiUrl = 'API URL',
  DbConnection = 'DB Connection',
  MetricsEnabled = 'Enable Prometheus Metrics',
  OgmiosUrl = 'Ogmios URL',
  RabbitMQUrl = 'RabbitMQ URL',
  UseQueue = 'Enables RabbitMQ',
  CardanoNodeConfigPath = 'Cardano node config path',
  CacheTtl = 'Cache TTL in minutes between 1 and 2880',
  EpochPollInterval = 'Epoch poll interval'
}

export type ProgramOptionDescriptions = CommonOptionDescriptions | HttpServerOptionDescriptions;
export const ProgramOptionDescriptions = { ...CommonOptionDescriptions, ...HttpServerOptionDescriptions };
