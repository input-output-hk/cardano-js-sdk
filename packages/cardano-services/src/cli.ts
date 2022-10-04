#!/usr/bin/env node

/* eslint-disable max-len */
/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable unicorn/no-nested-ternary */
import {
  API_URL_DEFAULT,
  CommonOptionDescriptions,
  ENABLE_METRICS_DEFAULT,
  HttpServerOptions,
  OGMIOS_URL_DEFAULT,
  PARALLEL_MODE_DEFAULT,
  PARALLEL_TXS_DEFAULT,
  POLLING_CYCLE_DEFAULT,
  ProgramOptionDescriptions,
  Programs,
  RABBITMQ_URL_DEFAULT,
  SERVICE_DISCOVERY_BACKOFF_FACTOR_DEFAULT,
  SERVICE_DISCOVERY_TIMEOUT_DEFAULT,
  ServiceNames,
  TxWorkerOptionDescriptions,
  TxWorkerOptions,
  USE_QUEUE_DEFAULT,
  WrongOption,
  loadAndStartTxWorker,
  loadHttpServer,
  loadSecret
} from './Program';
import { Command, Option } from 'commander';

import { DB_CACHE_TTL_DEFAULT } from './InMemoryCache';
import { DEFAULT_TOKEN_METADATA_CACHE_TTL, DEFAULT_TOKEN_METADATA_SERVER_URL } from './Asset';
import { EPOCH_POLL_INTERVAL_DEFAULT } from './util';
import { InvalidLoggerLevel } from './errors';
import { URL } from 'url';
import { cacheTtlValidator } from './util/validators';
import { loggerMethodNames } from '@cardano-sdk/util';
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
  if (['0', 'f', 'false'].includes(value)) return false;
  if (['1', 't', 'true'].includes(value)) return true;
  throw new WrongOption(program, option, ['false', 'true']);
};

const existingFileValidator = (filePath: string) => {
  if (fs.existsSync(filePath)) {
    return filePath;
  }
  throw new Error(`No file exists at ${filePath}`);
};
const getSecret = (secretFilePath?: string, secret?: string) =>
  secretFilePath ? loadSecret(secretFilePath) : secret ? secret : undefined;

const commonOptions = (command: Command) =>
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
      new Option('--ogmios-srv-service-name <ogmiosSrvServiceName>', CommonOptionDescriptions.OgmiosSrvServiceName).env(
        'OGMIOS_SRV_SERVICE_NAME'
      )
    )
    .addOption(
      new Option('--ogmios-url <ogmiosUrl>', CommonOptionDescriptions.OgmiosUrl)
        .env('OGMIOS_URL')
        .default(new URL(OGMIOS_URL_DEFAULT))
        .conflicts('ogmiosSrvServiceName')
        .argParser((url) => new URL(url))
    )
    .addOption(
      new Option(
        '--rabbitmq-srv-service-name <rabbitmqSrvServiceName>',
        CommonOptionDescriptions.RabbitMQSrvServiceName
      ).env('RABBITMQ_SRV_SERVICE_NAME')
    )
    .addOption(
      new Option('--rabbitmq-url <rabbitmqUrl>', CommonOptionDescriptions.RabbitMQUrl)
        .env('RABBITMQ_URL')
        .default(new URL(RABBITMQ_URL_DEFAULT))
        .conflicts('rabbitmqSrvServiceName')
        .argParser((url) => new URL(url))
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

const program = new Command('cardano-services');

program.version(packageJson.version);

commonOptions(
  program
    .command('start-server')
    .description('Start the HTTP server')
    .argument('[serviceNames...]', `List of services to attach: ${Object.values(ServiceNames).toString()}`)
)
  .addOption(
    new Option(
      '--service-names <serviceNames>',
      `List of services to attach: ${Object.values(ServiceNames).toString()}`
    )
      .env('SERVICE_NAMES')
      .argParser((names) => names.split(',') as ServiceNames[])
  )
  .addOption(
    new Option('--api-url <apiUrl>', ProgramOptionDescriptions.ApiUrl)
      .env('API_URL')
      .default(new URL(API_URL_DEFAULT))
      .argParser((url) => new URL(url))
  )
  .addOption(
    new Option('--enable-metrics <true/false>', ProgramOptionDescriptions.EnableMetrics)
      .env('ENABLE_METRICS')
      .default(ENABLE_METRICS_DEFAULT)
      .argParser((enableMetrics) =>
        stringToBoolean(enableMetrics, Programs.HttpServer, ProgramOptionDescriptions.EnableMetrics)
      )
  )
  .addOption(
    new Option(
      '--cardano-node-config-path <cardanoNodeConfigPath>',
      ProgramOptionDescriptions.CardanoNodeConfigPath
    ).env('CARDANO_NODE_CONFIG_PATH')
  )
  .addOption(
    new Option(
      '--postgres-connection-string <postgresConnectionString>',
      ProgramOptionDescriptions.PostgresConnectionString
    )
      .env('POSTGRES_CONNECTION_STRING')
      .conflicts('postgresSrvServiceName')
      .conflicts('postgresDb')
      .conflicts('postgresDbFile')
      .conflicts('postgresUser')
      .conflicts('postgresUserFile')
      .conflicts('postgresPassword')
      .conflicts('postgresPasswordFile')
      .conflicts('postgresHost')
      .conflicts('postgresPort')
  )
  .addOption(
    new Option('--postgres-srv-service-name <postgresSrvServiceName>', ProgramOptionDescriptions.PostgresSrvServiceName)
      .env('POSTGRES_SRV_SERVICE_NAME')
      .conflicts('postgresHost')
      .conflicts('postgresPort')
  )
  .addOption(
    new Option('--postgres-db <postgresDb>', ProgramOptionDescriptions.PostgresDb)
      .env('POSTGRES_DB')
      .conflicts('postgresDbFile')
  )
  .addOption(
    new Option('--postgres-db-file <postgresDbFile>', ProgramOptionDescriptions.PostgresDbFile)
      .env('POSTGRES_DB_FILE')
      .argParser(existingFileValidator)
  )
  .addOption(
    new Option('--postgres-user <postgresUser>', ProgramOptionDescriptions.PostgresUser)
      .env('POSTGRES_USER')
      .conflicts('postgresUserFile')
  )
  .addOption(
    new Option('--postgres-user-file <postgresUserFile>', ProgramOptionDescriptions.PostgresUserFile)
      .env('POSTGRES_USER_FILE')
      .argParser(existingFileValidator)
  )
  .addOption(
    new Option('--postgres-password <postgresPassword>', ProgramOptionDescriptions.PostgresPassword)
      .env('POSTGRES_PASSWORD')
      .conflicts('postgresPasswordFile')
  )
  .addOption(
    new Option('--postgres-password-file <postgresPasswordFile>', ProgramOptionDescriptions.PostgresPasswordFile)
      .env('POSTGRES_PASSWORD_FILE')
      .argParser(existingFileValidator)
  )
  .addOption(new Option('--postgres-host <postgresHost>', ProgramOptionDescriptions.PostgresHost).env('POSTGRES_HOST'))
  .addOption(new Option('--postgres-port <postgresPort>', ProgramOptionDescriptions.PostgresPort).env('POSTGRES_PORT'))
  .addOption(
    new Option('--postgres-ssl-ca-file <postgresSslCaFile>', ProgramOptionDescriptions.PostgresSslCaFile).env(
      'POSTGRES_SSL_CA_FILE'
    )
  )
  .addOption(
    new Option('--db-cache-ttl <dbCacheTtl>', ProgramOptionDescriptions.DbCacheTtl)
      .env('DB_CACHE_TTL')
      .default(DB_CACHE_TTL_DEFAULT)
      .argParser(cacheTtlValidator)
  )
  .addOption(
    new Option('--epoch-poll-interval <epochPollInterval>', ProgramOptionDescriptions.EpochPollInterval)
      .env('EPOCH_POLL_INTERVAL')
      .default(EPOCH_POLL_INTERVAL_DEFAULT)
      .argParser((interval) => Number.parseInt(interval, 10))
  )
  .addOption(
    new Option('--token-metadata-server-url <tokenMetadataServerUrl>', ProgramOptionDescriptions.TokenMetadataServerUrl)
      .env('TOKEN_METADATA_SERVER_URL')
      .default(DEFAULT_TOKEN_METADATA_SERVER_URL)
      .argParser((url) => new URL(url).toString())
  )
  .addOption(
    new Option('--token-metadata-cache-ttl <tokenMetadataCacheTTL>', ProgramOptionDescriptions.TokenMetadataCacheTtl)
      .env('TOKEN_METADATA_CACHE_TTL')
      .default(DEFAULT_TOKEN_METADATA_CACHE_TTL)
      .argParser(cacheTtlValidator)
  )
  .addOption(
    new Option('--use-queue <true/false>', ProgramOptionDescriptions.UseQueue)
      .env('USE_QUEUE')
      .default(USE_QUEUE_DEFAULT)
      .argParser((useQueue) => stringToBoolean(useQueue, Programs.HttpServer, ProgramOptionDescriptions.UseQueue))
  )
  .action(async (serviceNames: ServiceNames[], options: { apiUrl: URL } & HttpServerOptions) => {
    const { apiUrl, ...rest } = options;

    const dbName = getSecret(rest.postgresDbFile, rest.postgresDb);
    const dbUser = getSecret(rest.postgresUserFile, rest.postgresUser);
    const dbPassword = getSecret(rest.postgresPasswordFile, rest.postgresPassword);

    // Setting the connection string takes preference over secrets.
    // It can also remain undefined since there is no a default value. Usually used locally with static config.
    let postgresConnectionString;
    if (rest.postgresConnectionString) {
      postgresConnectionString = new URL(rest.postgresConnectionString).toString();
    } else if (dbName && dbPassword && dbUser && rest.postgresHost && rest.postgresPort) {
      postgresConnectionString = `postgresql://${dbUser}:${dbPassword}@${rest.postgresHost}:${rest.postgresPort}/${dbName}`;
    }

    // Setting the service names via env variable takes preference over command line argument
    const services = rest.serviceNames ? rest.serviceNames : serviceNames;
    try {
      const server = await loadHttpServer({
        apiUrl: apiUrl || API_URL_DEFAULT,
        options: { ...rest, postgresConnectionString },
        serviceNames: services
      });
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
  .addOption(
    new Option('--parallel <true/false>', TxWorkerOptionDescriptions.Parallel)
      .env('PARALLEL')
      .default(PARALLEL_MODE_DEFAULT)
      .argParser((parallel) => stringToBoolean(parallel, Programs.RabbitmqWorker, TxWorkerOptionDescriptions.Parallel))
  )
  .addOption(
    new Option('--parallel-txs <parallelTxs>', TxWorkerOptionDescriptions.ParallelTxs)
      .env('PARALLEL_TXS')
      .default(PARALLEL_TXS_DEFAULT)
      .argParser((parallelTxs) => Number.parseInt(parallelTxs, 10))
  )
  .addOption(
    new Option('--polling-cycle <pollingCycle>', TxWorkerOptionDescriptions.PollingCycle)
      .env('POLLING_CYCLE')
      .default(POLLING_CYCLE_DEFAULT)
      .argParser((pollingCycle) => Number.parseInt(pollingCycle, 10))
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
