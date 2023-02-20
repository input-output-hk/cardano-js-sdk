#!/usr/bin/env node

/* eslint-disable max-len */
/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable unicorn/no-nested-ternary */
import {
  API_URL_DEFAULT,
  CommonOptionDescriptions,
  ENABLE_METRICS_DEFAULT,
  HttpServerOptionDescriptions,
  HttpServerOptions,
  PAGINATION_PAGE_SIZE_LIMIT_DEFAULT,
  PARALLEL_MODE_DEFAULT,
  PARALLEL_TXS_DEFAULT,
  POLLING_CYCLE_DEFAULT,
  Programs,
  ServiceNames,
  TxWorkerOptionDescriptions,
  TxWorkerOptions,
  USE_QUEUE_DEFAULT,
  WrongOption,
  connectionStringFromOptions,
  loadAndStartTxWorker,
  loadHttpServer
} from './Program';
import { Command, Option } from 'commander';
import { DB_CACHE_TTL_DEFAULT } from './InMemoryCache';
import { DEFAULT_TOKEN_METADATA_CACHE_TTL, DEFAULT_TOKEN_METADATA_SERVER_URL } from './Asset';
import { EPOCH_POLL_INTERVAL_DEFAULT } from './util';
import { URL } from 'url';
import { buildInfoValidator, cacheTtlValidator } from './util/validators';
import { withCommonOptions, withOgmiosOptions, withPostgresOptions, withRabbitMqOptions } from './Program/options/';
import fs from 'fs';
import onDeath from 'death';
import path from 'path';

const copiedPackageJsonPath = path.join(__dirname, 'original-package.json');
// Exists in dist/, doesn't exist when run with ts-node
const packageJsonPath = fs.existsSync(copiedPackageJsonPath)
  ? copiedPackageJsonPath
  : path.join(__dirname, '../package.json');
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

// eslint-disable-next-line no-console
console.log('Cardano Services CLI');

const stringToBoolean = (value: string, program: Programs, option: string) => {
  if (['0', 'f', 'false'].includes(value)) return false;
  if (['1', 't', 'true'].includes(value)) return true;
  throw new WrongOption(program, option, ['false', 'true']);
};

const program = new Command('cardano-services');

program.version(packageJson.version);

withCommonOptions(
  withOgmiosOptions(
    withPostgresOptions(
      withRabbitMqOptions(
        program
          .command('start-server')
          .description('Start the HTTP server')
          .argument('[serviceNames...]', `List of services to attach: ${Object.values(ServiceNames).toString()}`)
      )
    )
  )
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
    new Option('--api-url <apiUrl>', HttpServerOptionDescriptions.ApiUrl)
      .env('API_URL')
      .default(new URL(API_URL_DEFAULT))
      .argParser((url) => new URL(url))
  )
  .addOption(
    new Option('--enable-metrics <true/false>', HttpServerOptionDescriptions.EnableMetrics)
      .env('ENABLE_METRICS')
      .default(ENABLE_METRICS_DEFAULT)
      .argParser((enableMetrics) =>
        stringToBoolean(enableMetrics, Programs.HttpServer, HttpServerOptionDescriptions.EnableMetrics)
      )
  )
  .addOption(
    new Option('--build-info <buildInfo>', HttpServerOptionDescriptions.BuildInfo)
      .env('BUILD_INFO')
      .argParser(buildInfoValidator)
  )
  .addOption(
    new Option(
      '--cardano-node-config-path <cardanoNodeConfigPath>',
      HttpServerOptionDescriptions.CardanoNodeConfigPath
    ).env('CARDANO_NODE_CONFIG_PATH')
  )
  .addOption(
    new Option('--db-cache-ttl <dbCacheTtl>', HttpServerOptionDescriptions.DbCacheTtl)
      .env('DB_CACHE_TTL')
      .default(DB_CACHE_TTL_DEFAULT)
      .argParser(cacheTtlValidator)
  )
  .addOption(
    new Option('--epoch-poll-interval <epochPollInterval>', HttpServerOptionDescriptions.EpochPollInterval)
      .env('EPOCH_POLL_INTERVAL')
      .default(EPOCH_POLL_INTERVAL_DEFAULT)
      .argParser((interval) => Number.parseInt(interval, 10))
  )
  .addOption(
    new Option(
      '--token-metadata-server-url <tokenMetadataServerUrl>',
      HttpServerOptionDescriptions.TokenMetadataServerUrl
    )
      .env('TOKEN_METADATA_SERVER_URL')
      .default(DEFAULT_TOKEN_METADATA_SERVER_URL)
      .argParser((url) => new URL(url).toString())
  )
  .addOption(
    new Option('--token-metadata-cache-ttl <tokenMetadataCacheTTL>', HttpServerOptionDescriptions.TokenMetadataCacheTtl)
      .env('TOKEN_METADATA_CACHE_TTL')
      .default(DEFAULT_TOKEN_METADATA_CACHE_TTL)
      .argParser(cacheTtlValidator)
  )
  .addOption(
    new Option('--use-queue <true/false>', HttpServerOptionDescriptions.UseQueue)
      .env('USE_QUEUE')
      .default(USE_QUEUE_DEFAULT)
      .argParser((useQueue) => stringToBoolean(useQueue, Programs.HttpServer, HttpServerOptionDescriptions.UseQueue))
  )
  .addOption(
    new Option(
      '--pagination-page-size-limit <paginationPageSizeLimit>',
      HttpServerOptionDescriptions.PaginationPageSizeLimit
    )
      .env('PAGINATION_PAGE_SIZE_LIMIT')
      .default(PAGINATION_PAGE_SIZE_LIMIT_DEFAULT)
      .argParser((interval) => Number.parseInt(interval, 10))
  )
  .action(async (serviceNames: ServiceNames[], options: { apiUrl: URL } & HttpServerOptions) => {
    const { apiUrl, ...rest } = options;

    // Setting the service names via env variable takes preference over command line argument
    const services = rest.serviceNames ? rest.serviceNames : serviceNames;
    try {
      const server = await loadHttpServer({
        apiUrl: apiUrl || API_URL_DEFAULT,
        options: { ...rest, postgresConnectionString: connectionStringFromOptions(options) },
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

withCommonOptions(
  withOgmiosOptions(withRabbitMqOptions(program.command('start-worker').description('Start RabbitMQ worker')))
)
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
      await txWorker.shutdown();
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
