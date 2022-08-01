#!/usr/bin/env node
import {
  API_URL_DEFAULT,
  HttpServerOptions,
  OGMIOS_URL_DEFAULT,
  ProgramOptionDescriptions,
  RABBITMQ_URL_DEFAULT,
  SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT,
  SERVICE_DISCOVERY_TIMEOUT_DEFAULT,
  ServiceNames,
  loadHttpServer
} from './Program';
import { Command } from 'commander';
import {
  CommonOptionDescriptions,
  ENABLE_METRICS_DEFAULT,
  Programs,
  USE_QUEUE_DEFAULT,
  WrongOption
} from './ProgramsCommon';
import { DB_CACHE_TTL_DEFAULT } from './InMemoryCache';
import { DEFAULT_TOKEN_METADATA_CACHE_TTL, DEFAULT_TOKEN_METADATA_SERVER_URL } from './Asset';
import { EPOCH_POLL_INTERVAL_DEFAULT } from './NetworkInfo';
import { InvalidLoggerLevel } from './errors';
import {
  PARALLEL_MODE_DEFAULT,
  PARALLEL_TXS_DEFAULT,
  POLLING_CYCLE_DEFAULT,
  TxWorkerOptionDescriptions,
  TxWorkerOptions,
  loadAndStartTxWorker
} from './TxWorker';
import { URL } from 'url';
import { cacheTtlValidator } from './util/validators';
import { loggerMethodNames } from './util';
import clear from 'clear';
import fs from 'fs';
import onDeath from 'death';
import path from 'path';

const copiedPackageJsonPath = path.join(__dirname, 'original-package.json');
// Exists in dist/, doesn't exist when run with ts-node
const packageJsonPath = fs.existsSync(copiedPackageJsonPath)
  ? copiedPackageJsonPath
  : path.join(__dirname, '../package.json');
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

clear();
// eslint-disable-next-line no-console
console.log('Cardano Services CLI');

const stringToBoolean = (value: string, program: Programs, option: string) => {
  // for compatibility: accepting same values as envalid in startWorker.ts
  if (['0', 'f', 'false'].includes(value)) return false;
  if (['1', 't', 'true'].includes(value)) return true;
  throw new WrongOption(program, option, ['false', 'true']);
};

const commonOptions = (command: Command) =>
  command
    .option(
      '--logger-min-severity <level>',
      CommonOptionDescriptions.LoggerMinSeverity,
      (level) => {
        if (!loggerMethodNames.includes(level)) {
          throw new InvalidLoggerLevel(level);
        }
        return level;
      },
      'info'
    )
    .option(
      '--ogmios-url <ogmiosUrl>',
      CommonOptionDescriptions.OgmiosUrl,
      (url) => new URL(url),
      new URL(OGMIOS_URL_DEFAULT)
    )
    .option(
      '--rabbitmq-url <rabbitMQUrl>',
      CommonOptionDescriptions.RabbitMQUrl,
      (url) => new URL(url),
      new URL(RABBITMQ_URL_DEFAULT)
    )
    .option('--ogmios-srv-service-name <ogmiosSrvServiceName>', ProgramOptionDescriptions.OgmiosSrvServiceName)
    .option('--rabbitmq-srv-service-name <rabbitmqSrvServiceName>', ProgramOptionDescriptions.RabbitMQSrvServiceName)
    .option(
      '--service-discovery-backoff-factor <serviceDiscoveryBackoffFactor>',
      ProgramOptionDescriptions.ServiceDiscoveryBackoffFactor,
      (factor) => Number.parseFloat(factor),
      SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT
    )
    .option(
      '--service-discovery-timeout <serviceDiscoveryTimeout>',
      ProgramOptionDescriptions.ServiceDiscoveryTimeout,
      (interval) => Number.parseInt(interval, 10),
      SERVICE_DISCOVERY_TIMEOUT_DEFAULT
    );

const program = new Command('cardano-services');

program.version(packageJson.version);

commonOptions(
  program
    .command('start-server')
    .description('Start the HTTP server')
    .argument('<serviceNames...>', `List of services to attach: ${Object.values(ServiceNames).toString()}`)
)
  .option('--api-url <apiUrl>', ProgramOptionDescriptions.ApiUrl, (url) => new URL(url), new URL(API_URL_DEFAULT))
  .option('--enable-metrics', ProgramOptionDescriptions.EnableMetrics, () => true, ENABLE_METRICS_DEFAULT)
  .option(
    '--postgres-connection-string <postgresConnectionString>',
    ProgramOptionDescriptions.PostgresConnectionString,
    (url) => new URL(url).toString()
  )
  .option('--cardano-node-config-path <cardanoNodeConfigPath>', ProgramOptionDescriptions.CardanoNodeConfigPath)
  .option('--db-cache-ttl <dbCacheTtl>', ProgramOptionDescriptions.DbCacheTtl, cacheTtlValidator, DB_CACHE_TTL_DEFAULT)
  .option(
    '--epoch-poll-interval <epochPollInterval>',
    ProgramOptionDescriptions.EpochPollInterval,
    (interval) => Number.parseInt(interval, 10),
    EPOCH_POLL_INTERVAL_DEFAULT
  )
  .option(
    '--token-metadata-cache-ttl <tokenMetadataCacheTTL>',
    ProgramOptionDescriptions.TokenMetadataCacheTtl,
    cacheTtlValidator,
    DEFAULT_TOKEN_METADATA_CACHE_TTL
  )
  .option(
    '--token-metadata-server-url <tokenMetadataServerUrl>',
    ProgramOptionDescriptions.TokenMetadataServerUrl,
    (url) => new URL(url).toString(),
    DEFAULT_TOKEN_METADATA_SERVER_URL
  )
  .option('--use-queue', ProgramOptionDescriptions.UseQueue, () => true, USE_QUEUE_DEFAULT)
  .option('--postgres-srv-service-name <postgresSrvServiceName>', ProgramOptionDescriptions.PostgresSrvServiceName)
  .option('--postgres-db <postgresDb>', ProgramOptionDescriptions.PostgresDb)
  .option('--postgres-user <postgresUser>', ProgramOptionDescriptions.PostgresUser)
  .option('--postgres-password <postgresPassword>', ProgramOptionDescriptions.PostgresPassword)
  .option('--postgres-ssl-ca-file <postgresSslCaFile>', ProgramOptionDescriptions.PostgresSslCaFile)
  .action(async (serviceNames: ServiceNames[], options: { apiUrl: URL } & HttpServerOptions) => {
    const { apiUrl, ...rest } = options;
    try {
      const server = await loadHttpServer({ apiUrl: apiUrl || API_URL_DEFAULT, options: rest, serviceNames });
      await server.initialize();
      await server.start();
      onDeath(async () => {
        await server.shutdown();
        process.exit(1);
      });
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(error);
      process.exit(1);
    }
  });

commonOptions(program.command('start-worker').description('Start RabbitMQ worker'))
  .option(
    '--parallel [parallel]',
    TxWorkerOptionDescriptions.Parallel,
    (parallel) => stringToBoolean(parallel, Programs.RabbitmqWorker, TxWorkerOptionDescriptions.Parallel),
    PARALLEL_MODE_DEFAULT
  )
  .option(
    '--parallel-txs <parallelTxs>',
    TxWorkerOptionDescriptions.ParallelTxs,
    (parallelTxs) => Number.parseInt(parallelTxs, 10),
    PARALLEL_TXS_DEFAULT
  )
  .option(
    '--polling-cycle <pollingCycle>',
    TxWorkerOptionDescriptions.PollingCycle,
    (pollingCycle) => Number.parseInt(pollingCycle, 10),
    POLLING_CYCLE_DEFAULT
  )
  .action(async (options: TxWorkerOptions) => {
    // eslint-disable-next-line no-console
    console.log(`RabbitMQ transactions worker: ${options.parallel ? 'parallel' : 'serial'} mode`);
    const txWorker = await loadAndStartTxWorker({ options });
    onDeath(async () => {
      await txWorker.stop();
      process.exit(1);
    });
  });

if (process.argv.slice(2).length === 0) {
  program.outputHelp();
  process.exit(1);
} else {
  program.parseAsync(process.argv).catch((error) => {
    // eslint-disable-next-line no-console
    console.error(error);
    process.exit(1);
  });
}
