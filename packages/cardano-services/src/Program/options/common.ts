import { Command } from 'commander';
import { DB_CACHE_TTL_DEFAULT } from '../../InMemoryCache';
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
import {
  buildInfoValidator,
  dbCacheValidator,
  floatValidator,
  integerValidator,
  urlValidator
} from '../../util/validators';
import { loggerMethodNames } from '@cardano-sdk/util';

export const DEFAULT_HEALTH_CHECK_CACHE_TTL = Seconds(5);
export const LAST_ROS_EPOCHS_DEFAULT = 10;

export enum CommonOptionsDescriptions {
  ApiUrl = 'API URL',
  BuildInfo = 'Service build info',
  CardanoNodeConfigPath = 'Cardano node config path',
  DbCacheTtl = 'Cache TTL in seconds between 60 and 172800 (two days), an option for database related operations',
  DisableDbCache = 'Disable DB cache',
  DumpOnly = 'Dumps the input arguments and exits. Used for tests',
  HeartbeatInterval = 'WebSocket client heartbeat interval in seconds',
  HeartbeatTimeout = 'WebSocket client heartbeat timeout in seconds',
  EnableMetrics = 'Enable Prometheus Metrics',
  LastRosEpochs = 'Number of epochs over which lastRos is computed',
  LoggerMinSeverity = 'Log level',
  ServiceDiscoveryBackoffFactor = 'Exponential backoff factor for service discovery',
  ServiceDiscoveryTimeout = 'Timeout for service discovery attempts',
  WebSocketApiUrl = 'WebSocket API server URL'
}

export type CommonProgramOptions = {
  apiUrl: URL;
  buildInfo?: ServiceBuildInfo;
  cardanoNodeConfigPath?: string;
  dbCacheTtl: Seconds | 0;
  disableDbCache?: boolean;
  dumpOnly?: boolean;
  enableMetrics?: boolean;
  heartbeatInterval?: number;
  heartbeatTimeout?: number;
  lastRosEpochs?: number;
  loggerMinSeverity?: LogLevel;
  serviceDiscoveryBackoffFactor?: number;
  serviceDiscoveryTimeout?: number;
  webSocketApiUrl?: URL;
} & { [k in keyof typeof ServiceNames as `${Uncapitalize<k>}ProviderUrl`]?: string };

export const withCommonOptions = (command: Command, apiUrl: URL) => {
  addOptions(command, [
    newOption(
      '--api-url <apiUrl>',
      CommonOptionsDescriptions.ApiUrl,
      'API_URL',
      urlValidator(CommonOptionsDescriptions.ApiUrl),
      apiUrl
    ),
    newOption('--build-info <buildInfo>', CommonOptionsDescriptions.BuildInfo, 'BUILD_INFO', buildInfoValidator),
    newOption(
      '--cardano-node-config-path <cardanoNodeConfigPath>',
      CommonOptionsDescriptions.CardanoNodeConfigPath,
      'CARDANO_NODE_CONFIG_PATH'
    ),
    newOption(
      '--db-cache-ttl <dbCacheTtl>',
      CommonOptionsDescriptions.DbCacheTtl,
      'DB_CACHE_TTL',
      dbCacheValidator(CommonOptionsDescriptions.DbCacheTtl),
      DB_CACHE_TTL_DEFAULT
    ),
    newOption(
      '--disable-db-cache <true/false>',
      CommonOptionsDescriptions.DisableDbCache,
      'DISABLE_DB_CACHE',
      (disableDbCache) =>
        stringOptionToBoolean(disableDbCache, Programs.ProviderServer, CommonOptionsDescriptions.DisableDbCache)
    ),
    newOption('--dump-only <true/false>', CommonOptionsDescriptions.DumpOnly, 'DUMP_ONLY', (dumpOnly) =>
      stringOptionToBoolean(dumpOnly, Programs.ProviderServer, CommonOptionsDescriptions.DumpOnly)
    ),
    newOption(
      '--enable-metrics <true/false>',
      CommonOptionsDescriptions.EnableMetrics,
      'ENABLE_METRICS',
      (enableMetrics) =>
        stringOptionToBoolean(enableMetrics, Programs.ProviderServer, CommonOptionsDescriptions.EnableMetrics)
    ),
    newOption(
      '--heartbeat-interval <heartbeatInterval>',
      CommonOptionsDescriptions.HeartbeatInterval,
      'HEARTBEAT_INTERVAL',
      integerValidator(CommonOptionsDescriptions.HeartbeatInterval)
    ),
    newOption(
      '--heartbeat-timeout <heartbeatTimeout>',
      CommonOptionsDescriptions.HeartbeatTimeout,
      'HEARTBEAT_TIMEOUT',
      integerValidator(CommonOptionsDescriptions.HeartbeatTimeout)
    ),
    newOption(
      '--last-ros-epochs <lastRosEpochs>',
      CommonOptionsDescriptions.LastRosEpochs,
      'LAST_ROS_EPOCHS',
      integerValidator(CommonOptionsDescriptions.LastRosEpochs),
      LAST_ROS_EPOCHS_DEFAULT
    ),
    newOption(
      '--logger-min-severity <level>',
      CommonOptionsDescriptions.LoggerMinSeverity,
      'LOGGER_MIN_SEVERITY',
      (level) => {
        if (!loggerMethodNames.includes(level)) throw new InvalidLoggerLevel(level);
        return level;
      },
      'info'
    ),
    newOption(
      '--service-discovery-backoff-factor <serviceDiscoveryBackoffFactor>',
      CommonOptionsDescriptions.ServiceDiscoveryBackoffFactor,
      'SERVICE_DISCOVERY_BACKOFF_FACTOR',
      floatValidator(CommonOptionsDescriptions.ServiceDiscoveryBackoffFactor),
      SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT
    ),
    newOption(
      '--service-discovery-timeout <serviceDiscoveryTimeout>',
      CommonOptionsDescriptions.ServiceDiscoveryTimeout,
      'SERVICE_DISCOVERY_TIMEOUT',
      integerValidator(CommonOptionsDescriptions.ServiceDiscoveryTimeout),
      SERVICE_DISCOVERY_TIMEOUT_DEFAULT
    ),
    newOption(
      '--web-socket-api-url <webSocketApiUrl>',
      CommonOptionsDescriptions.WebSocketApiUrl,
      'WEB_SOCKET_API_URL',
      urlValidator(CommonOptionsDescriptions.WebSocketApiUrl)
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
