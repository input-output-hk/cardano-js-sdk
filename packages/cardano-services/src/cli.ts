#!/usr/bin/env node

/* eslint-disable max-len */
/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable unicorn/no-nested-ternary */
import { Command, Option } from 'commander';
import { DB_CACHE_TTL_DEFAULT } from './InMemoryCache';
import { DEFAULT_TOKEN_METADATA_CACHE_TTL, DEFAULT_TOKEN_METADATA_SERVER_URL } from './Asset';
import { EPOCH_POLL_INTERVAL_DEFAULT } from './util';
import {
  HTTP_SERVER_API_URL_DEFAULT,
  HttpServerArgs,
  HttpServerOptionDescriptions,
  PAGINATION_PAGE_SIZE_LIMIT_DEFAULT,
  PARALLEL_MODE_DEFAULT,
  PARALLEL_TXS_DEFAULT,
  POLLING_CYCLE_DEFAULT,
  Programs,
  ServiceNames,
  TX_WORKER_API_URL_DEFAULT,
  TxWorkerArgs,
  TxWorkerOptionDescriptions,
  USE_QUEUE_DEFAULT,
  connectionStringFromArgs,
  loadAndStartTxWorker,
  loadHttpServer,
  stringOptionToBoolean
} from './Program';
import { URL } from 'url';
import { cacheTtlValidator } from './util/validators';
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
  ),
  {
    apiUrl: HTTP_SERVER_API_URL_DEFAULT
  }
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
      .argParser((useQueue) =>
        stringOptionToBoolean(useQueue, Programs.HttpServer, HttpServerOptionDescriptions.UseQueue)
      )
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
  .action(async (serviceNames: ServiceNames[], args: { apiUrl: URL } & HttpServerArgs) => {
    try {
      const server = await loadHttpServer({
        ...args,
        postgresConnectionString: connectionStringFromArgs(args),
        // Setting the service names via env variable takes preference over command line argument
        serviceNames: args.serviceNames ? args.serviceNames : serviceNames
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
  withOgmiosOptions(withRabbitMqOptions(program.command('start-worker').description('Start RabbitMQ worker'))),
  {
    apiUrl: TX_WORKER_API_URL_DEFAULT
  }
)
  .addOption(
    new Option('--parallel <true/false>', TxWorkerOptionDescriptions.Parallel)
      .env('PARALLEL')
      .default(PARALLEL_MODE_DEFAULT)
      .argParser((parallel) =>
        stringOptionToBoolean(parallel, Programs.RabbitmqWorker, TxWorkerOptionDescriptions.Parallel)
      )
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
  .action(async (args: TxWorkerArgs) => {
    // eslint-disable-next-line no-console
    console.log(`RabbitMQ transactions worker: ${args.parallel ? 'parallel' : 'serial'} mode`);
    const txWorker = await loadAndStartTxWorker(args);
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
