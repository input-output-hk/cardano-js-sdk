#!/usr/bin/env node

import {
  ALLOWED_ORIGINS_DEFAULT,
  AvailableNetworks,
  BLOCKFROST_WORKER_API_URL_DEFAULT,
  BLOCKS_BUFFER_LENGTH_DEFAULT,
  BlockfrostWorkerArgs,
  BlockfrostWorkerOptionDescriptions,
  CACHE_TTL_DEFAULT,
  CREATE_SCHEMA_DEFAULT,
  DISABLE_DB_CACHE_DEFAULT,
  DISABLE_STAKE_POOL_METRIC_APY_DEFAULT,
  DROP_SCHEMA_DEFAULT,
  DRY_RUN_DEFAULT,
  HANDLE_PROVIDER_SERVER_URL_DEFAULT,
  METADATA_JOB_RETRY_DELAY_DEFAULT,
  PAGINATION_PAGE_SIZE_LIMIT_DEFAULT,
  PARALLEL_JOBS_DEFAULT,
  PG_BOSS_WORKER_API_URL_DEFAULT,
  POOLS_METRICS_INTERVAL_DEFAULT,
  POOLS_METRICS_OUTDATED_INTERVAL_DEFAULT,
  PROJECTOR_API_URL_DEFAULT,
  PROVIDER_SERVER_API_URL_DEFAULT,
  PgBossWorkerArgs,
  PgBossWorkerOptionDescriptions,
  Programs,
  ProjectorArgs,
  ProjectorOptionDescriptions,
  ProviderServerArgs,
  ProviderServerOptionDescriptions,
  SCAN_INTERVAL_DEFAULT,
  ServiceNames,
  USE_BLOCKFROST_DEFAULT,
  USE_TYPEORM_ASSET_PROVIDER_DEFAULT,
  USE_TYPEORM_STAKE_POOL_PROVIDER_DEFAULT,
  addOptions,
  availableNetworks,
  connectionStringFromArgs,
  loadBlockfrostWorker,
  loadPgBossWorker,
  loadProjector,
  loadProviderServer,
  newOption,
  stringOptionToBoolean,
  withCommonOptions,
  withHandlePolicyIdsOptions,
  withOgmiosOptions,
  withPostgresOptions,
  withStakePoolMetadataOptions
} from './Program';
import { Command } from 'commander';
import { DB_CACHE_TTL_DEFAULT } from './InMemoryCache';
import {
  DEFAULT_TOKEN_METADATA_CACHE_TTL,
  DEFAULT_TOKEN_METADATA_REQUEST_TIMEOUT,
  DEFAULT_TOKEN_METADATA_SERVER_URL
} from './Asset';
import { EPOCH_POLL_INTERVAL_DEFAULT } from './util';
import { HttpServer } from './Http';
import { PgBossQueue, isValidQueue } from './PgBoss';
import { ProjectionName } from './Projection';
import { dbCacheValidator } from './util/validators';
import { readScheduleConfig } from './util/schedule';
import fs from 'fs';
import onDeath from 'death';
import path from 'path';

const copiedPackageJsonPath = path.join(__dirname, 'original-package.json');
// Exists in dist/, doesn't exist when run with ts-node
const packageJsonPath = fs.existsSync(copiedPackageJsonPath)
  ? copiedPackageJsonPath
  : path.join(__dirname, '../package.json');
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
const projectionNameParser = (names: string) => names.split(',') as ProjectionName[];

process.on('unhandledRejection', (reason) => {
  // To be handled by 'onDeath'
  throw reason;
});

process.stdout.write('Cardano Services CLI\n');

const program = new Command('cardano-services');

program.version(packageJson.version);

const runServer = async (message: string, loadServer: () => Promise<HttpServer>) => {
  try {
    process.stdout.write(`${message}\n`);
    const server = await loadServer();

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
};

const projector = program
  .command('start-projector')
  .description('Start a projector')
  .argument(
    '[projectionNames...]',
    `List of projections to start: ${Object.values(ProjectionName).toString()}`,
    projectionNameParser
  );
const projectorWithArgs = withOgmiosOptions(withPostgresOptions(withHandlePolicyIdsOptions(projector), ['']));

addOptions(withCommonOptions(projectorWithArgs, PROJECTOR_API_URL_DEFAULT), [
  newOption(
    '--blocks-buffer-length <blocksBufferLength>',
    ProjectorOptionDescriptions.BlocksBufferLength,
    'BLOCKS_BUFFER_LENGTH',
    (blocksBufferLength) => Number.parseInt(blocksBufferLength, 10),
    BLOCKS_BUFFER_LENGTH_DEFAULT
  ),
  newOption(
    '--drop-schema <true/false>',
    ProjectorOptionDescriptions.DropSchema,
    'DROP_SCHEMA',
    (dropSchema) => stringOptionToBoolean(dropSchema, Programs.Projector, ProjectorOptionDescriptions.DropSchema),
    false
  ),
  newOption(
    '--dry-run <true/false>',
    BlockfrostWorkerOptionDescriptions.DryRun,
    'DRY_RUN',
    (dryRun) => stringOptionToBoolean(dryRun, Programs.Projector, ProjectorOptionDescriptions.DryRun),
    DRY_RUN_DEFAULT
  ),
  newOption(
    '--exit-at-block-no <exitAtBlockNo>',
    ProjectorOptionDescriptions.ExitAtBlockNo,
    'EXIT_AT_BLOCK_NO',
    (exitAtBlockNo) => (exitAtBlockNo ? Number.parseInt(exitAtBlockNo, 10) : 0),
    ''
  ),
  newOption(
    '--metadata-job-retry-delay <metadataJobRetryDelay>',
    ProjectorOptionDescriptions.MetadataJobRetryDelay,
    'METADATA_JOB_RETRY_DELAY',
    (metadataJobRetryDelay) => Number.parseInt(metadataJobRetryDelay, 10),
    METADATA_JOB_RETRY_DELAY_DEFAULT
  ),
  newOption(
    '--pools-metrics-interval <poolsMetricsInterval>',
    ProjectorOptionDescriptions.PoolsMetricsInterval,
    'POOLS_METRICS_INTERVAL',
    (interval) => Number.parseInt(interval, 10),
    POOLS_METRICS_INTERVAL_DEFAULT
  ),
  newOption(
    '--pools-metrics-outdated-interval <poolsMetricsOutdatedInterval>',
    ProjectorOptionDescriptions.PoolsMetricsOutdatedInterval,
    'POOLS_METRICS_OUTDATED_INTERVAL',
    (interval) => Number.parseInt(interval, 10),
    POOLS_METRICS_OUTDATED_INTERVAL_DEFAULT
  ),
  newOption(
    '--projection-names <projectionNames>',
    `List of projections to start: ${Object.values(ProjectionName).toString()}`,
    'PROJECTION_NAMES',
    projectionNameParser
  ),
  newOption(
    '--synchronize <true/false>',
    ProjectorOptionDescriptions.Synchronize,
    'SYNCHRONIZE',
    (synchronize) => stringOptionToBoolean(synchronize, Programs.Projector, ProjectorOptionDescriptions.Synchronize),
    false
  )
]).action(async (projectionNames: ProjectionName[], args: { apiUrl: URL } & ProjectorArgs) =>
  runServer('projector', () =>
    loadProjector({
      ...args,
      postgresConnectionString: connectionStringFromArgs(args, ''),
      // Setting the projection names via env variable takes preference over command line argument
      projectionNames: args.projectionNames ? args.projectionNames : projectionNames
    })
  )
);

const providerServer = program
  .command('start-provider-server')
  .description('Start the Provider Server')
  .argument('[serviceNames...]', `List of services to attach: ${Object.values(ServiceNames).toString()}`);
const providerServerWithPostgres = withPostgresOptions(providerServer, ['Asset', 'DbSync', 'Handle', 'StakePool']);
const providerServerWithCommon = withCommonOptions(providerServerWithPostgres, PROVIDER_SERVER_API_URL_DEFAULT);

addOptions(withOgmiosOptions(withHandlePolicyIdsOptions(providerServerWithCommon)), [
  newOption(
    '--service-names <serviceNames>',
    `List of services to attach: ${Object.values(ServiceNames).toString()}`,
    'SERVICE_NAMES',
    (names) => names.split(',') as ServiceNames[]
  ),
  newOption(
    '--allowed-origins <allowedOrigins>',
    ProviderServerOptionDescriptions.AllowedOrigins,
    'ALLOWED_ORIGINS',
    (originsList) => originsList.split(',') as string[],
    ALLOWED_ORIGINS_DEFAULT
  ),
  newOption(
    '--cardano-node-config-path <cardanoNodeConfigPath>',
    ProviderServerOptionDescriptions.CardanoNodeConfigPath,
    'CARDANO_NODE_CONFIG_PATH'
  ),
  newOption(
    '--db-cache-ttl <dbCacheTtl>',
    ProviderServerOptionDescriptions.DbCacheTtl,
    'DB_CACHE_TTL',
    dbCacheValidator,
    DB_CACHE_TTL_DEFAULT
  ),
  newOption(
    '--disable-db-cache <true/false>',
    ProviderServerOptionDescriptions.DisableDbCache,
    'DISABLE_DB_CACHE',
    (disableDbCache) =>
      stringOptionToBoolean(disableDbCache, Programs.ProviderServer, ProviderServerOptionDescriptions.DisableDbCache),
    DISABLE_DB_CACHE_DEFAULT
  ),
  newOption(
    '--disable-stake-pool-metric-apy <true/false>',
    ProviderServerOptionDescriptions.DisableStakePoolMetricApy,
    'DISABLE_STAKE_POOL_METRIC_APY',
    (disableApy) =>
      stringOptionToBoolean(
        disableApy,
        Programs.ProviderServer,
        ProviderServerOptionDescriptions.DisableStakePoolMetricApy
      ),
    DISABLE_STAKE_POOL_METRIC_APY_DEFAULT
  ),
  newOption(
    '--epoch-poll-interval <epochPollInterval>',
    ProviderServerOptionDescriptions.EpochPollInterval,
    'EPOCH_POLL_INTERVAL',
    (interval) => Number.parseInt(interval, 10),
    EPOCH_POLL_INTERVAL_DEFAULT
  ),
  newOption(
    '--submit-api-url <submitApiUrl>',
    ProviderServerOptionDescriptions.SubmitApiUrl,
    'SUBMIT_API_URL',
    (url) => new URL(url)
  ),
  newOption(
    '--token-metadata-server-url <tokenMetadataServerUrl>',
    ProviderServerOptionDescriptions.TokenMetadataServerUrl,
    'TOKEN_METADATA_SERVER_URL',
    (url) => new URL(url).toString(),
    DEFAULT_TOKEN_METADATA_SERVER_URL
  ),
  newOption(
    '--token-metadata-cache-ttl <tokenMetadataCacheTTL>',
    ProviderServerOptionDescriptions.TokenMetadataCacheTtl,
    'TOKEN_METADATA_CACHE_TTL',
    dbCacheValidator,
    DEFAULT_TOKEN_METADATA_CACHE_TTL
  ),
  newOption(
    '--asset-cache-ttl <assetCacheTTL>',
    ProviderServerOptionDescriptions.AssetCacheTtl,
    'ASSET_CACHE_TTL',
    dbCacheValidator,
    DB_CACHE_TTL_DEFAULT
  ),
  newOption(
    '--token-metadata-request-timeout <tokenMetadataRequestTimeout>',
    ProviderServerOptionDescriptions.PaginationPageSizeLimit,
    'TOKEN_METADATA_REQUEST_TIMEOUT',
    (interval) => Number.parseInt(interval, 10),
    DEFAULT_TOKEN_METADATA_REQUEST_TIMEOUT
  ),
  newOption(
    '--use-typeorm-stake-pool-provider <true/false>',
    ProviderServerOptionDescriptions.UseTypeOrmStakePoolProvider,
    'USE_TYPEORM_STAKE_POOL_PROVIDER',
    (useTypeormStakePoolProvider) =>
      stringOptionToBoolean(
        useTypeormStakePoolProvider,
        Programs.ProviderServer,
        ProviderServerOptionDescriptions.UseTypeOrmStakePoolProvider
      ),
    USE_TYPEORM_STAKE_POOL_PROVIDER_DEFAULT
  ),
  newOption(
    '--use-blockfrost <true/false>',
    ProviderServerOptionDescriptions.UseBlockfrost,
    'USE_BLOCKFROST',
    (useBlockfrost) =>
      stringOptionToBoolean(useBlockfrost, Programs.ProviderServer, ProviderServerOptionDescriptions.UseBlockfrost),
    USE_BLOCKFROST_DEFAULT
  ),
  newOption(
    '--use-kora-labs <true/false>',
    ProviderServerOptionDescriptions.UseKoraLabsProvider,
    'USE_KORA_LABS',
    (useKoraLabs) =>
      stringOptionToBoolean(useKoraLabs, Programs.ProviderServer, ProviderServerOptionDescriptions.UseKoraLabsProvider),
    false
  ),
  newOption(
    '--submit-validate-handles <true/false>',
    ProviderServerOptionDescriptions.SubmitValidateHandles,
    'SUBMIT_VALIDATE_HANDLES',
    (submitValidateHandles) =>
      stringOptionToBoolean(
        submitValidateHandles,
        Programs.ProviderServer,
        ProviderServerOptionDescriptions.SubmitValidateHandles
      ),
    false
  ),
  newOption(
    '--pagination-page-size-limit <paginationPageSizeLimit>',
    ProviderServerOptionDescriptions.PaginationPageSizeLimit,
    'PAGINATION_PAGE_SIZE_LIMIT',
    (interval) => Number.parseInt(interval, 10),
    PAGINATION_PAGE_SIZE_LIMIT_DEFAULT
  ),
  newOption(
    '--handle-provider-server-url <handleProviderServerUrl>',
    ProviderServerOptionDescriptions.HandleProviderServerUrl,
    'HANDLE_PROVIDER_SERVER_URL',
    (serverUrl: string) => serverUrl,
    HANDLE_PROVIDER_SERVER_URL_DEFAULT
  ),
  newOption(
    '--use-submit-api <true/false>',
    ProviderServerOptionDescriptions.UseSubmitApi,
    'USE_SUBMIT_API',
    (value) => stringOptionToBoolean(value, Programs.ProviderServer, ProviderServerOptionDescriptions.UseSubmitApi),
    false
  ),
  newOption(
    '--use-typeorm-asset-provider <true/false>',
    ProviderServerOptionDescriptions.UseTypeormAssetProvider,
    'USE_TYPEORM_ASSET_PROVIDER',
    (useTypeormAssetProvider) =>
      stringOptionToBoolean(
        useTypeormAssetProvider,
        Programs.ProviderServer,
        ProviderServerOptionDescriptions.UseTypeormAssetProvider
      ),
    USE_TYPEORM_ASSET_PROVIDER_DEFAULT
  )
]).action(async (serviceNames: ServiceNames[], args: ProviderServerArgs) =>
  runServer('Provider server', () =>
    loadProviderServer({
      ...args,
      postgresConnectionStringAsset: connectionStringFromArgs(args, 'Asset'),
      postgresConnectionStringDbSync: connectionStringFromArgs(args, 'DbSync'),
      postgresConnectionStringHandle: connectionStringFromArgs(args, 'Handle'),
      postgresConnectionStringStakePool: connectionStringFromArgs(args, 'StakePool'),
      serviceNames: args.serviceNames ? args.serviceNames : serviceNames
    })
  )
);

const blockfrost = program.command('start-blockfrost-worker').description('Start the Blockfrost worker');

addOptions(withCommonOptions(withPostgresOptions(blockfrost, ['DbSync']), BLOCKFROST_WORKER_API_URL_DEFAULT), [
  newOption(
    '--blockfrost-api-file <blockfrostApiFile>',
    BlockfrostWorkerOptionDescriptions.BlockfrostApiFile,
    'BLOCKFROST_API_FILE'
  ).conflicts('blockfrostApiKey'),
  newOption(
    '--blockfrost-api-key <blockfrostApiKey>',
    BlockfrostWorkerOptionDescriptions.BlockfrostApiKey,
    'BLOCKFROST_API_KEY'
  ),
  newOption(
    '--cache-ttl <cacheTtl>',
    BlockfrostWorkerOptionDescriptions.CacheTTL,
    'CACHE_TTL',
    (interval) => Number.parseInt(interval, 10),
    CACHE_TTL_DEFAULT
  ),
  newOption(
    '--create-schema <true/false>',
    BlockfrostWorkerOptionDescriptions.CreateSchema,
    'CREATE_SCHEMA',
    (createSchema) =>
      stringOptionToBoolean(createSchema, Programs.BlockfrostWorker, BlockfrostWorkerOptionDescriptions.CreateSchema),
    CREATE_SCHEMA_DEFAULT
  ),
  newOption(
    '--drop-schema <true/false>',
    BlockfrostWorkerOptionDescriptions.DropSchema,
    'DROP_SCHEMA',
    (dropSchema) =>
      stringOptionToBoolean(dropSchema, Programs.BlockfrostWorker, BlockfrostWorkerOptionDescriptions.DropSchema),
    DROP_SCHEMA_DEFAULT
  ),
  newOption(
    '--dry-run <true/false>',
    BlockfrostWorkerOptionDescriptions.DryRun,
    'DRY_RUN',
    (dryRun) => stringOptionToBoolean(dryRun, Programs.BlockfrostWorker, BlockfrostWorkerOptionDescriptions.DryRun),
    DRY_RUN_DEFAULT
  ),
  newOption('--network <network>', BlockfrostWorkerOptionDescriptions.Network, 'NETWORK', (network) => {
    if (availableNetworks.includes(network as AvailableNetworks)) return network;

    throw new Error(`Unknown network: ${network}`);
  }),
  newOption(
    '--scan-interval <scanInterval>',
    BlockfrostWorkerOptionDescriptions.ScanInterval,
    'SCAN_INTERVAL',
    (interval) => Number.parseInt(interval, 10),
    SCAN_INTERVAL_DEFAULT
  )
]).action(async (args: BlockfrostWorkerArgs) =>
  runServer('Blockfrost worker', () =>
    loadBlockfrostWorker({ ...args, postgresConnectionStringDbSync: connectionStringFromArgs(args, 'DbSync') })
  )
);

const pgBoss = program.command('start-pg-boss-worker').description('Start the pg-boss worker');

addOptions(
  withCommonOptions(
    withStakePoolMetadataOptions(withPostgresOptions(pgBoss, ['DbSync', 'StakePool'])),
    PG_BOSS_WORKER_API_URL_DEFAULT
  ),
  [
    newOption(
      '--parallel-jobs <parallelJobs>',
      PgBossWorkerOptionDescriptions.ParallelJobs,
      'PARALLEL_JOBS',
      (parallelJobs) => Number.parseInt(parallelJobs, 10),
      PARALLEL_JOBS_DEFAULT
    ),
    newOption('--queues <queues>', PgBossWorkerOptionDescriptions.Queues, 'QUEUES', (queues) => {
      const queuesArray = queues.split(',') as PgBossQueue[];

      for (const queue of queuesArray) if (!isValidQueue(queue)) throw new Error(`Unknown queue name: '${queue}'`);

      return queuesArray;
    }).makeOptionMandatory(),
    newOption(
      '--schedules <schedules>',
      PgBossWorkerOptionDescriptions.Queues,
      'SCHEDULES',
      (schedules) => {
        if (!fs.existsSync(schedules)) throw new Error(`File does not exist: ${schedules}`);
        return readScheduleConfig(schedules);
      },
      []
    )
  ]
).action(async (args: PgBossWorkerArgs) =>
  runServer('pg-boss worker', () =>
    loadPgBossWorker({
      ...args,
      postgresConnectionStringDbSync: connectionStringFromArgs(args, 'DbSync'),
      postgresConnectionStringStakePool: connectionStringFromArgs(args, 'StakePool')
    })
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
