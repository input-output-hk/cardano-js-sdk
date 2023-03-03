import { Command, Option } from 'commander';
import { InvalidLoggerLevel } from '../../errors';
import { LogLevel } from 'bunyan';
import { Programs } from '../programs';
import {
  SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT,
  SERVICE_DISCOVERY_TIMEOUT_DEFAULT,
  stringOptionToBoolean
} from '../utils';
import { BuildInfo as ServiceBuildInfo } from '../../Http';
import { URL } from 'url';
import { buildInfoValidator } from '../../util/validators';
import { loggerMethodNames } from '@cardano-sdk/util';

export const ENABLE_METRICS_DEFAULT = false;

export enum CommonOptionDescriptions {
  ApiUrl = 'API URL',
  BuildInfo = 'Service build info',
  LoggerMinSeverity = 'Log level',
  EnableMetrics = 'Enable Prometheus Metrics',
  ServiceDiscoveryBackoffFactor = 'Exponential backoff factor for service discovery',
  ServiceDiscoveryTimeout = 'Timeout for service discovery attempts'
}

export interface CommonProgramOptions {
  apiUrl: URL;
  buildInfo?: ServiceBuildInfo;
  enableMetrics?: boolean;
  loggerMinSeverity?: LogLevel;
  serviceDiscoveryBackoffFactor?: number;
  serviceDiscoveryTimeout?: number;
}

export const withCommonOptions = (command: Command, defaults: { apiUrl: URL }) =>
  command
    .addOption(
      new Option('--api-url <apiUrl>', CommonOptionDescriptions.ApiUrl)
        .env('API_URL')
        .default(defaults.apiUrl)
        .argParser((url) => new URL(url))
    )
    .addOption(
      new Option('--build-info <buildInfo>', CommonOptionDescriptions.BuildInfo)
        .env('BUILD_INFO')
        .argParser(buildInfoValidator)
    )
    .addOption(
      new Option('--enable-metrics <true/false>', CommonOptionDescriptions.EnableMetrics)
        .env('ENABLE_METRICS')
        .default(ENABLE_METRICS_DEFAULT)
        .argParser((enableMetrics) =>
          stringOptionToBoolean(enableMetrics, Programs.ProviderServer, CommonOptionDescriptions.EnableMetrics)
        )
    )
    .addOption(
      new Option('--logger-min-severity <level>', CommonOptionDescriptions.LoggerMinSeverity)
        .env('LOGGER_MIN_SEVERITY')
        .default('info')
        .argParser((level) => {
          if (!loggerMethodNames.includes(level)) {
            throw new InvalidLoggerLevel(level);
          }
          return level;
        })
    )
    .addOption(
      new Option(
        '--service-discovery-backoff-factor <serviceDiscoveryBackoffFactor>',
        CommonOptionDescriptions.ServiceDiscoveryBackoffFactor
      )
        .env('SERVICE_DISCOVERY_BACKOFF_FACTOR')
        .default(SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT)
        .argParser((factor) => Number.parseFloat(factor))
    )
    .addOption(
      new Option(
        '--service-discovery-timeout <serviceDiscoveryTimeout>',
        CommonOptionDescriptions.ServiceDiscoveryTimeout
      )
        .env('SERVICE_DISCOVERY_TIMEOUT')
        .default(SERVICE_DISCOVERY_TIMEOUT_DEFAULT)
        .argParser((interval) => Number.parseInt(interval, 10))
    );
