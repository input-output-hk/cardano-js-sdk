import { CommonOptionDescriptions } from '../ProgramsCommon';

enum HttpServerOptionDescriptions {
  ApiUrl = 'API URL',
  DbConnection = 'DB Connection',
  MetricsEnabled = 'Enable Prometheus Metrics',
  UseQueue = 'Enables RabbitMQ'
}

export type ProgramOptionDescriptions = CommonOptionDescriptions | HttpServerOptionDescriptions;
export const ProgramOptionDescriptions = { ...CommonOptionDescriptions, ...HttpServerOptionDescriptions };
