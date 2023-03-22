#!/usr/bin/env node

/* eslint-disable no-console */
/* eslint-disable complexity */
/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable unicorn/no-nested-ternary */
import {
  AvailableNetworks,
  BLOCKFROST_WORKER_API_URL_DEFAULT,
  BlockfrostWorkerArgs,
  BlockfrostWorkerOptionDescriptions,
  CACHE_TTL_DEFAULT,
  CREATE_SCHEMA_DEFAULT,
  DISABLE_DB_CACHE_DEFAULT,
  DISABLE_STAKE_POOL_METRIC_APY_DEFAULT,
  DROP_SCHEMA_DEFAULT,
  DRY_RUN_DEFAULT,
  HTTP_SERVER_API_URL_DEFAULT,
  PAGINATION_PAGE_SIZE_LIMIT_DEFAULT,
  PARALLEL_MODE_DEFAULT,
  PARALLEL_TXS_DEFAULT,
  POLLING_CYCLE_DEFAULT,
  Programs,
  ProviderServerArgs,
  ProviderServerOptionDescriptions,
  SCAN_INTERVAL_DEFAULT,
  ServiceNames,
  TX_WORKER_API_URL_DEFAULT,
  TxWorkerArgs,
  TxWorkerOptionDescriptions,
  USE_BLOCKFROST_DEFAULT,
  USE_QUEUE_DEFAULT,
  availableNetworks,
  connectionStringFromArgs,
  loadAndStartTxWorker,
  loadBlockfrostWorker,
  loadProviderServer,
  stringOptionToBoolean
} from './Program';
import { Command, Option } from 'commander';
import { DB_CACHE_TTL_DEFAULT } from './InMemoryCache';
import { DEFAULT_TOKEN_METADATA_CACHE_TTL, DEFAULT_TOKEN_METADATA_SERVER_URL } from './Asset';
import { EPOCH_POLL_INTERVAL_DEFAULT } from './util';
import { HttpServer } from './Http';
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

process.on('unhandledRejection', (reason) => {
  // To be handled by 'onDeath'
  throw reason;
});

console.log('Cardano Services CLI');

const program = new Command('cardano-services');

program.version(packageJson.version);

const runServer = async (message: string, loadServer: () => Promise<HttpServer>) => {
  try {
    console.log(message);
    const server = await loadServer();

    await server.initialize();
    await server.start();

    onDeath(async () => {
      await server.shutdown();
      process.exit(1);
    });
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};

withCommonOptions(
  withOgmiosOptions(
    withPostgresOptions(
      withRabbitMqOptions(
        program
          .command('start-provider-server')
          .description('Start the Provider Server')
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
      ProviderServerOptionDescriptions.CardanoNodeConfigPath
    ).env('CARDANO_NODE_CONFIG_PATH')
  )
  .addOption(
    new Option('--db-cache-ttl <dbCacheTtl>', ProviderServerOptionDescriptions.DbCacheTtl)
      .env('DB_CACHE_TTL')
      .default(DB_CACHE_TTL_DEFAULT)
      .argParser(cacheTtlValidator)
  )
  .addOption(
    new Option('--disable-db-cache <true/false>', ProviderServerOptionDescriptions.DisableDbCache)
      .env('DISABLE_DB_CACHE')
      .default(DISABLE_DB_CACHE_DEFAULT)
      .argParser((disableDbCache) =>
        stringOptionToBoolean(disableDbCache, Programs.ProviderServer, ProviderServerOptionDescriptions.DisableDbCache)
      )
  )
  .addOption(
    new Option(
      '--disable-stake-pool-metric-apy <true/false>',
      ProviderServerOptionDescriptions.DisableStakePoolMetricApy
    )
      .env('DISABLE_STAKE_POOL_METRIC_APY')
      .default(DISABLE_STAKE_POOL_METRIC_APY_DEFAULT)
      .argParser((disableStakePoolMetricApy) =>
        stringOptionToBoolean(
          disableStakePoolMetricApy,
          Programs.ProviderServer,
          ProviderServerOptionDescriptions.DisableStakePoolMetricApy
        )
      )
  )
  .addOption(
    new Option('--epoch-poll-interval <epochPollInterval>', ProviderServerOptionDescriptions.EpochPollInterval)
      .env('EPOCH_POLL_INTERVAL')
      .default(EPOCH_POLL_INTERVAL_DEFAULT)
      .argParser((interval) => Number.parseInt(interval, 10))
  )
  .addOption(
    new Option(
      '--token-metadata-server-url <tokenMetadataServerUrl>',
      ProviderServerOptionDescriptions.TokenMetadataServerUrl
    )
      .env('TOKEN_METADATA_SERVER_URL')
      .default(DEFAULT_TOKEN_METADATA_SERVER_URL)
      .argParser((url) => new URL(url).toString())
  )
  .addOption(
    new Option(
      '--token-metadata-cache-ttl <tokenMetadataCacheTTL>',
      ProviderServerOptionDescriptions.TokenMetadataCacheTtl
    )
      .env('TOKEN_METADATA_CACHE_TTL')
      .default(DEFAULT_TOKEN_METADATA_CACHE_TTL)
      .argParser(cacheTtlValidator)
  )
  .addOption(
    new Option('--use-blockfrost <true/false>', ProviderServerOptionDescriptions.UseBlockfrost)
      .env('USE_BLOCKFROST')
      .default(USE_BLOCKFROST_DEFAULT)
      .argParser((useBlockfrost) =>
        stringOptionToBoolean(useBlockfrost, Programs.ProviderServer, ProviderServerOptionDescriptions.UseBlockfrost)
      )
  )
  .addOption(
    new Option('--use-queue <true/false>', ProviderServerOptionDescriptions.UseQueue)
      .env('USE_QUEUE')
      .default(USE_QUEUE_DEFAULT)
      .argParser((useQueue) =>
        stringOptionToBoolean(useQueue, Programs.ProviderServer, ProviderServerOptionDescriptions.UseQueue)
      )
  )
  .addOption(
    new Option(
      '--pagination-page-size-limit <paginationPageSizeLimit>',
      ProviderServerOptionDescriptions.PaginationPageSizeLimit
    )
      .env('PAGINATION_PAGE_SIZE_LIMIT')
      .default(PAGINATION_PAGE_SIZE_LIMIT_DEFAULT)
      .argParser((interval) => Number.parseInt(interval, 10))
  )
  .action(async (serviceNames: ServiceNames[], args: ProviderServerArgs) =>
    runServer('Provider server', () =>
      loadProviderServer({
        ...args,
        postgresConnectionString: connectionStringFromArgs(args),
        // Setting the service names via env variable takes preference over command line argument
        serviceNames: args.serviceNames ? args.serviceNames : serviceNames
      })
    )
  );

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

withCommonOptions(
  withPostgresOptions(program.command('start-blockfrost-worker').description('Start the Blockfrost worker')),
  {
    apiUrl: BLOCKFROST_WORKER_API_URL_DEFAULT
  }
)
  .addOption(
    new Option('--blockfrost-api-file <blockfrostApiFile>', BlockfrostWorkerOptionDescriptions.BlockfrostApiFile)
      .env('BLOCKFROST_API_FILE')
      .conflicts('blockfrostApiKey')
  )
  .addOption(
    new Option('--blockfrost-api-key <blockfrostApiKey>', BlockfrostWorkerOptionDescriptions.BlockfrostApiKey).env(
      'BLOCKFROST_API_KEY'
    )
  )
  .addOption(
    new Option('--cache-ttl <cacheTtl>', BlockfrostWorkerOptionDescriptions.CacheTTL)
      .env('CACHE_TTL')
      .default(CACHE_TTL_DEFAULT)
      .argParser((interval) => Number.parseInt(interval, 10))
  )
  .addOption(
    new Option('--create-schema <true/false>', BlockfrostWorkerOptionDescriptions.CreateSchema)
      .env('CREATE_SCHEMA')
      .default(CREATE_SCHEMA_DEFAULT)
      .argParser((createSchema) =>
        stringOptionToBoolean(createSchema, Programs.BlockfrostWorker, BlockfrostWorkerOptionDescriptions.CreateSchema)
      )
  )
  .addOption(
    new Option('--drop-schema <true/false>', BlockfrostWorkerOptionDescriptions.DropSchema)
      .env('DROP_SCHEMA')
      .default(DROP_SCHEMA_DEFAULT)
      .argParser((dropSchema) =>
        stringOptionToBoolean(dropSchema, Programs.BlockfrostWorker, BlockfrostWorkerOptionDescriptions.DropSchema)
      )
  )
  .addOption(
    new Option('--dry-run <true/false>', BlockfrostWorkerOptionDescriptions.DryRun)
      .env('DRY_RUN')
      .default(DRY_RUN_DEFAULT)
      .argParser((dryRun) =>
        stringOptionToBoolean(dryRun, Programs.BlockfrostWorker, BlockfrostWorkerOptionDescriptions.DryRun)
      )
  )
  .addOption(
    new Option('--network <network>', BlockfrostWorkerOptionDescriptions.Network)
      .env('NETWORK')
      .argParser((network) => {
        if (availableNetworks.includes(network as AvailableNetworks)) return network;

        throw new Error(`Unknown network: ${network}`);
      })
  )
  .addOption(
    new Option('--scan-interval <scanInterval>', BlockfrostWorkerOptionDescriptions.ScanInterval)
      .env('SCAN_INTERVAL')
      .default(SCAN_INTERVAL_DEFAULT)
      .argParser((interval) => Number.parseInt(interval, 10))
  )
  .action(async (args: BlockfrostWorkerArgs) =>
    runServer('Blockfrost worker', () =>
      loadBlockfrostWorker({ ...args, postgresConnectionString: connectionStringFromArgs(args) })
    )
  );

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
