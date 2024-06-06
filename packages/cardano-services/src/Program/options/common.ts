import { InvalidLoggerLevel } from '../../errors/index.js';
import { MissingProgramOption } from '../errors/index.js';
import { Programs, ServiceNames } from '../programs/types.js';
import {
  SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT,
  SERVICE_DISCOVERY_TIMEOUT_DEFAULT,
  stringOptionToBoolean
} from '../utils.js';
import { Seconds } from '@cardano-sdk/core';
import { addOptions, newOption } from './util.js';
import { buildInfoValidator, floatValidator, integerValidator, urlValidator } from '../../util/validators.js';
import { loggerMethodNames } from '@cardano-sdk/util';
import type { Command } from 'commander';
import type { LogLevel } from 'bunyan';
import type { BuildInfo as ServiceBuildInfo } from '../../Http/index.js';

export const ENABLE_METRICS_DEFAULT = false;
export const DEFAULT_HEALTH_CHECK_CACHE_TTL = Seconds(5);
export const LAST_ROS_EPOCHS_DEFAULT = 10;

enum Descriptions {
  ApiUrl = 'API URL',
  BuildInfo = 'Service build info',
  DumpOnly = 'Dumps the input arguments and exits. Used for tests',
  EnableMetrics = 'Enable Prometheus Metrics',
  LastRosEpochs = 'Number of epochs over which lastRos is computed',
  LoggerMinSeverity = 'Log level',
  ServiceDiscoveryBackoffFactor = 'Exponential backoff factor for service discovery',
  ServiceDiscoveryTimeout = 'Timeout for service discovery attempts'
}

export type CommonProgramOptions = {
  apiUrl: URL;
  buildInfo?: ServiceBuildInfo;
  dumpOnly?: boolean;
  enableMetrics?: boolean;
  lastRosEpochs?: number;
  loggerMinSeverity?: LogLevel;
  serviceDiscoveryBackoffFactor?: number;
  serviceDiscoveryTimeout?: number;
} & { [k in keyof typeof ServiceNames as `${Uncapitalize<k>}ProviderUrl`]?: string };

export const withCommonOptions = (command: Command, apiUrl: URL) => {
  addOptions(command, [
    newOption('--api-url <apiUrl>', Descriptions.ApiUrl, 'API_URL', urlValidator(Descriptions.ApiUrl), apiUrl),
    newOption('--build-info <buildInfo>', Descriptions.BuildInfo, 'BUILD_INFO', buildInfoValidator),
    newOption('--dump-only <true/false>', Descriptions.DumpOnly, 'DUMP_ONLY', (dumpOnly) =>
      stringOptionToBoolean(dumpOnly, Programs.ProviderServer, Descriptions.DumpOnly)
    ),
    newOption(
      '--enable-metrics <true/false>',
      Descriptions.EnableMetrics,
      'ENABLE_METRICS',
      (enableMetrics) => stringOptionToBoolean(enableMetrics, Programs.ProviderServer, Descriptions.EnableMetrics),
      ENABLE_METRICS_DEFAULT
    ),
    newOption(
      '--last-ros-epochs <lastRosEpochs>',
      Descriptions.LastRosEpochs,
      'LAST_ROS_EPOCHS',
      integerValidator(Descriptions.LastRosEpochs),
      LAST_ROS_EPOCHS_DEFAULT
    ),
    newOption(
      '--logger-min-severity <level>',
      Descriptions.LoggerMinSeverity,
      'LOGGER_MIN_SEVERITY',
      (level) => {
        if (!loggerMethodNames.includes(level)) throw new InvalidLoggerLevel(level);
        return level;
      },
      'info'
    ),
    newOption(
      '--service-discovery-backoff-factor <serviceDiscoveryBackoffFactor>',
      Descriptions.ServiceDiscoveryBackoffFactor,
      'SERVICE_DISCOVERY_BACKOFF_FACTOR',
      floatValidator(Descriptions.ServiceDiscoveryBackoffFactor),
      SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT
    ),
    newOption(
      '--service-discovery-timeout <serviceDiscoveryTimeout>',
      Descriptions.ServiceDiscoveryTimeout,
      'SERVICE_DISCOVERY_TIMEOUT',
      integerValidator(Descriptions.ServiceDiscoveryTimeout),
      SERVICE_DISCOVERY_TIMEOUT_DEFAULT
    )
  ]);

  let service: keyof typeof ServiceNames;
  for (service in ServiceNames) {
    const cliService = service.replace(/[A-Z]/g, (_) => `-${_.toLowerCase()}`);
    const envService = service
      .replace(/[A-Z]/g, (_) => `_${_}`)
      .replace(/[a-z]/g, (_) => _.toUpperCase())
      .slice(1);
    const typService = service.charAt(0).toLowerCase() + service.slice(1);

    command.addOption(
      newOption(
        `-${cliService}-provider-url <${typService}ProviderUrl>`,
        `${service} provider URL`,
        `${envService}_PROVIDER_URL`,
        (url) => new URL(url).toString()
      )
    );
  }

  return command;
};

export const missingProviderUrlOption = (service: string, provider: ServiceNames) =>
  new MissingProgramOption(service, `${provider} provider URL`);
