import { Command } from 'commander';
import { InvalidLoggerLevel } from '../../errors';
import { LogLevel } from 'bunyan';
import { MissingProgramOption } from '../errors';
import { Programs, ServiceNames } from '../programs/types';
import {
  SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT,
  SERVICE_DISCOVERY_TIMEOUT_DEFAULT,
  stringOptionToBoolean
} from '../utils';
import { Seconds } from '@cardano-sdk/core';
import { BuildInfo as ServiceBuildInfo } from '../../Http';
import { addOptions, newOption } from './util';
import { buildInfoValidator, cacheTtlValidator } from '../../util/validators';
import { loggerMethodNames } from '@cardano-sdk/util';

export const ENABLE_METRICS_DEFAULT = false;
export const DEFAULT_HEALTH_CHECK_CACHE_TTL = Seconds(5);
export const LAST_ROS_EPOCHS_DEFAULT = 10;

enum Descriptions {
  ApiUrl = 'API URL',
  BuildInfo = 'Service build info',
  LastRosEpochs = 'Number of epochs over which lastRos is computed',
  LoggerMinSeverity = 'Log level',
  HealthCheckCacheTtl = 'Health check cache TTL in seconds between 1 and 10',
  EnableMetrics = 'Enable Prometheus Metrics',
  ServiceDiscoveryBackoffFactor = 'Exponential backoff factor for service discovery',
  ServiceDiscoveryTimeout = 'Timeout for service discovery attempts'
}

export type CommonProgramOptions = {
  apiUrl: URL;
  buildInfo?: ServiceBuildInfo;
  enableMetrics?: boolean;
  lastRosEpochs?: number;
  loggerMinSeverity?: LogLevel;
  serviceDiscoveryBackoffFactor?: number;
  serviceDiscoveryTimeout?: number;
} & { [k in keyof typeof ServiceNames as `${Uncapitalize<k>}ProviderUrl`]?: string };

export const withCommonOptions = (command: Command, apiUrl: URL) => {
  addOptions(command, [
    newOption('--api-url <apiUrl>', Descriptions.ApiUrl, 'API_URL', (url) => new URL(url), apiUrl),
    newOption('--build-info <buildInfo>', Descriptions.BuildInfo, 'BUILD_INFO', buildInfoValidator),
    newOption(
      '--enable-metrics <true/false>',
      Descriptions.EnableMetrics,
      'ENABLE_METRICS',
      (enableMetrics) => stringOptionToBoolean(enableMetrics, Programs.ProviderServer, Descriptions.EnableMetrics),
      ENABLE_METRICS_DEFAULT
    ),
    newOption(
      '--health-check-cache-ttl <healthCheckCacheTTL>',
      Descriptions.HealthCheckCacheTtl,
      'HEALTH_CHECK_CACHE_TTL',
      (ttl: string) => cacheTtlValidator(ttl, { lowerBound: 1, upperBound: 120 }, Descriptions.HealthCheckCacheTtl),
      DEFAULT_HEALTH_CHECK_CACHE_TTL
    ),
    newOption(
      '--last-ros-epochs <lastRosEpochs>',
      Descriptions.LastRosEpochs,
      'LAST_ROS_EPOCHS',
      (lastRosEpochs) => Number.parseInt(lastRosEpochs, 10),
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
      (factor) => Number.parseFloat(factor),
      SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT
    ),
    newOption(
      '--service-discovery-timeout <serviceDiscoveryTimeout>',
      Descriptions.ServiceDiscoveryTimeout,
      'SERVICE_DISCOVERY_TIMEOUT',
      (interval) => Number.parseInt(interval, 10),
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
