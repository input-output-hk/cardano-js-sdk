import { Command, Option } from 'commander';
import { InvalidLoggerLevel } from '../../errors';
import { LogLevel } from 'bunyan';
import { SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT, SERVICE_DISCOVERY_TIMEOUT_DEFAULT } from '../utils';
import { loggerMethodNames } from '@cardano-sdk/util';

export enum CommonOptionDescriptions {
  LoggerMinSeverity = 'Log level',
  ServiceDiscoveryBackoffFactor = 'Exponential backoff factor for service discovery',
  ServiceDiscoveryTimeout = 'Timeout for service discovery attempts'
}

export interface CommonProgramOptions {
  loggerMinSeverity?: LogLevel;
  serviceDiscoveryBackoffFactor?: number;
  serviceDiscoveryTimeout?: number;
}

export const withCommonOptions = (command: Command) =>
  command
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
