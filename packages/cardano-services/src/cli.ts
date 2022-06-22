#!/usr/bin/env node
import {
  API_URL_DEFAULT,
  HttpServerOptions,
  OGMIOS_URL_DEFAULT,
  ProgramOptionDescriptions,
  RABBITMQ_URL_DEFAULT,
  ServiceNames,
  loadHttpServer
} from './Program';
import { CACHE_TTL_DEFAULT } from './InMemoryCache';
import { Command } from 'commander';
import { CommonOptionDescriptions, Programs, USE_QUEUE_DEFAULT, WrongOption } from './ProgramsCommon';
import { EPOCH_POLL_INTERVAL_DEFAULT } from './NetworkInfo';
import { InvalidLoggerLevel } from './errors';
import {
  PARALLEL_MODE_DEFAULT,
  PARALLEL_TXS_DEFAULT,
  POLLING_CYCLE_DEFAULT,
  TxWorkerOptionDescriptions,
  TxWorkerOptions,
  loadTxWorker
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
  .option('--enable-metrics <metricsEnabled>', ProgramOptionDescriptions.MetricsEnabled, false)
  .option('--db-connection-string <dbConnectionString>', ProgramOptionDescriptions.DbConnection, (url) =>
    new URL(url).toString()
  )
  .option('--cardano-node-config-path <cardanoNodeConfigPath>', ProgramOptionDescriptions.CardanoNodeConfigPath)
  .option('--cache-ttl <cacheTtl>', ProgramOptionDescriptions.CacheTtl, cacheTtlValidator, CACHE_TTL_DEFAULT)
  .option(
    '--epoch-poll-interval <epochPollInterval>',
    ProgramOptionDescriptions.EpochPollInterval,
    (interval) => Number.parseInt(interval, 10),
    EPOCH_POLL_INTERVAL_DEFAULT
  )
  .option('--use-queue', ProgramOptionDescriptions.UseQueue, () => true, USE_QUEUE_DEFAULT)
  .action(async (serviceNames: ServiceNames[], options: { apiUrl: URL } & HttpServerOptions) => {
    const { apiUrl, ...rest } = options;
    const server = await loadHttpServer({ apiUrl: apiUrl || API_URL_DEFAULT, options: rest, serviceNames });
    await server.initialize();
    await server.start();
    onDeath(async () => {
      await server.shutdown();
      process.exit(1);
    });
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
    const txWorker = await loadTxWorker({ options });
    await txWorker.start();
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
