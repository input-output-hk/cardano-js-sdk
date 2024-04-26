/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable sonarjs/no-duplicate-string */
import { DEFAULT_FUZZY_SEARCH_OPTIONS } from '../src';
import { createLogger } from '@cardano-sdk/util-dev';
import { fork } from 'child_process';
import path from 'path';

const exePath = path.join(__dirname, '..', 'dist', 'cjs', 'cli.js');
const logger = createLogger({ env: process.env.TL_LEVEL ? process.env : { ...process.env, TL_LEVEL: 'error' } });
const queues = ['pool-metadata', 'pool-metrics', 'pool-rewards'];

const HANDLE_POLICY_IDS = 'f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a';
const { POSTGRES_CONNECTION_STRING_DB_SYNC, POSTGRES_CONNECTION_STRING_STAKE_POOL } = process.env;
const QUEUES = queues.join(',');

const programs = {
  blockfrost: 'start-blockfrost-worker',
  pgboss: 'start-pg-boss-worker',
  projector: 'start-projector',
  provider: 'start-provider-server'
};

type Program = keyof typeof programs;

type RunCli = {
  args?: string[];
  env?: NodeJS.ProcessEnv;
  expectedArgs?: unknown;
  expectedError?: string;
  expectedOutput?: string;
  notDump?: boolean;
};

const runCli = (
  program: Program,
  { args = [], env = {}, expectedArgs, expectedError, expectedOutput, notDump }: RunCli
) =>
  new Promise<void>((resolve, reject) => {
    const chunks = { stderr: [] as string[], stdout: [] as string[] };
    const method = { stderr: expectedError ? 'debug' : 'error', stdout: 'info' } as const;
    const argv = [programs[program], ...(notDump ? [] : ['--dump-only', 'true']), ...args];
    const proc = fork(exePath, argv, { env, stdio: 'pipe' });

    const assert = (assertions: () => void) => {
      try {
        assertions();
      } catch (error) {
        reject(error);
      }
    };

    for (const stream of ['stderr', 'stdout'] as const)
      proc[stream]!.on('data', (data) => {
        const str = data.toString();

        logger[method[stream]](str);
        chunks[stream].push(str);
      });

    proc.on('error', (error) => assert(() => expect(error).toBeUndefined()));

    proc.on('close', (code) => {
      assert(() => {
        const stderr = chunks.stderr.join('');
        const stdout = chunks.stdout.join('');

        if (expectedArgs) {
          const [, dump] = stdout.split('\n');

          expect(stderr).toBe('');
          expect(JSON.parse(dump)).toMatchObject(expectedArgs);
        }

        if (expectedError) expect(stderr).toContain(expectedError);
        if (expectedOutput) expect(stdout).toContain(expectedOutput);
        expect(code).toBe(expectedError || expectedOutput ? 1 : 0);
      });
      resolve();
    });
  });

const testCli = (name: string, program: Program, args: RunCli) => {
  test(`cmd - ${name}`, async () => {
    const { env: _, ...rest } = args;

    await runCli(program, rest);
  });

  test(`env - ${name}`, async () => {
    const { args: _, ...rest } = args;

    await runCli(program, rest);
  });
};

const testBlockfrost = (name: string, program: Program, _args: RunCli) => {
  const { args, env, expectedArgs, expectedError } = { args: [], env: {}, ..._args };

  return testCli(name, program, {
    args: ['--network', 'mainnet', ...args],
    env: { NETWORK: 'mainnet', ...env },
    expectedArgs,
    expectedError
  });
};

const testPgBoss = (name: string, program: Program, _args: RunCli) => {
  const { args, env, expectedArgs, expectedError } = { args: [], env: {}, ..._args };

  return testCli(name, program, {
    args: ['--queues', QUEUES, ...args],
    env: { QUEUES, ...env },
    expectedArgs,
    expectedError
  });
};

describe('CLI', () => {
  const notDump = true;

  describe('withCommonOptions', () => {
    describe('apiUrl', () => {
      const apiUrl = 'http://test.url/';

      testCli('accepts a valid URL', 'provider', {
        args: ['--api-url', apiUrl],
        env: { API_URL: apiUrl },
        expectedArgs: { args: { apiUrl } }
      });

      testCli('expects a valid URL', 'provider', {
        args: ['--api-url', 'test'],
        env: { API_URL: 'test' },
        expectedError: 'API URL - "test" is not an URL'
      });
    });

    describe('buildInfo', () => {
      const badInfo = '{"not":"a build info"}';
      const buildInfo = { extra: {}, lastModified: 23, lastModifiedDate: 'date', rev: 'rev', shortRev: 'short' };

      testCli('accepts a valid build info object', 'provider', {
        args: ['--build-info', JSON.stringify(buildInfo)],
        env: { BUILD_INFO: JSON.stringify(buildInfo) },
        expectedArgs: { args: { buildInfo } }
      });

      testCli('expects a JSON encoded string', 'provider', {
        args: ['--build-info', 'test'],
        env: { BUILD_INFO: 'test' },
        expectedError: 'Invalid JSON format of build-info'
      });

      testCli('expects a valid build info object', 'provider', {
        args: ['--build-info', badInfo],
        env: { BUILD_INFO: badInfo },
        expectedError: 'is not allowed to have the additional property "not"'
      });
    });

    describe('enableMetrics', () => {
      testCli('accepts a valid boolean', 'provider', {
        args: ['--enable-metrics', 'true'],
        env: { ENABLE_METRICS: 'true' },
        expectedArgs: { args: { enableMetrics: true } }
      });

      testCli('expects a valid boolean', 'provider', {
        args: ['--enable-metrics', 'test'],
        env: { ENABLE_METRICS: 'test' },
        expectedError: 'Provider server requires a valid Enable Prometheus Metrics program option'
      });
    });

    describe('lastRosEpochs', () => {
      testCli('accepts an integer', 'provider', {
        args: ['--last-ros-epochs', '23'],
        env: { LAST_ROS_EPOCHS: '23' },
        expectedArgs: { args: { lastRosEpochs: 23 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--last-ros-epochs', 'test'],
        env: { LAST_ROS_EPOCHS: 'test' },
        expectedError: 'Number of epochs over which lastRos is computed - "test" is not an integer'
      });
    });

    describe('loggerMinSeverity', () => {
      testCli('accepts a valid log level', 'provider', {
        args: ['--logger-min-severity', 'debug'],
        env: { LOGGER_MIN_SEVERITY: 'debug' },
        expectedArgs: { args: { loggerMinSeverity: 'debug' } }
      });

      testCli('expects a valid log level', 'provider', {
        args: ['--logger-min-severity', 'test'],
        env: { LOGGER_MIN_SEVERITY: 'test' },
        expectedError: 'InvalidLoggerLevel: test is an invalid logger level'
      });
    });

    describe('serviceDiscoveryBackoffFactor', () => {
      testCli('accepts a float', 'provider', {
        args: ['--service-discovery-backoff-factor', '.23'],
        env: { SERVICE_DISCOVERY_BACKOFF_FACTOR: '0.23' },
        expectedArgs: { args: { serviceDiscoveryBackoffFactor: 0.23 } }
      });

      testCli('expects a float', 'provider', {
        args: ['--service-discovery-backoff-factor', 'test'],
        env: { SERVICE_DISCOVERY_BACKOFF_FACTOR: 'test' },
        expectedError: 'Exponential backoff factor for service discovery - "test" is not a number'
      });
    });

    describe('serviceDiscoveryTimeout', () => {
      testCli('accepts an integer', 'provider', {
        args: ['--service-discovery-timeout', '23'],
        env: { SERVICE_DISCOVERY_TIMEOUT: '23' },
        expectedArgs: { args: { serviceDiscoveryTimeout: 23 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--service-discovery-timeout', 'test'],
        env: { SERVICE_DISCOVERY_TIMEOUT: 'test' },
        expectedError: 'Timeout for service discovery attempts - "test" is not an integer'
      });
    });
  });

  describe('withHandlePolicyIdsOptions', () => {
    describe('handlePolicyIds', () => {
      testCli('accepts a valid PolicyId array', 'provider', {
        args: ['--handle-policy-ids', HANDLE_POLICY_IDS],
        env: { HANDLE_POLICY_IDS },
        expectedArgs: { args: { handlePolicyIds: [HANDLE_POLICY_IDS] } }
      });

      testCli('expects a valid PolicyId array', 'provider', {
        args: ['--handle-policy-ids', 'test'],
        env: { HANDLE_POLICY_IDS: 'test' },
        expectedError: 'Invalid string: "expected length \'56\', got 4"'
      });
    });

    describe('handlePolicyIds', () => {
      testCli('accepts any string', 'provider', {
        args: ['--handle-policy-ids-file', 'test'],
        env: { HANDLE_POLICY_IDS_FILE: 'test' },
        expectedArgs: { args: { handlePolicyIdsFile: 'test' } }
      });
    });

    describe('conflicts', () => {
      test('handlePolicyIds conflicts with handlePolicyIdsFile', () =>
        runCli('provider', {
          env: { HANDLE_POLICY_IDS, HANDLE_POLICY_IDS_FILE: 'test' },
          expectedError: "'HANDLE_POLICY_IDS_FILE' cannot be used with environment variable 'HANDLE_POLICY_IDS'"
        }));
    });
  });

  describe('withOgmiosOptions', () => {
    const ogmiosUrl = 'wss://test/';

    describe('ogmiosUrl', () => {
      testCli('accepts an URL', 'provider', {
        args: ['--ogmios-url', ogmiosUrl],
        env: { OGMIOS_URL: ogmiosUrl },
        expectedArgs: { args: { ogmiosUrl } }
      });

      testCli('expects an URL', 'provider', {
        args: ['--ogmios-url', 'test'],
        env: { OGMIOS_URL: 'test' },
        expectedError: 'Ogmios URL - "test" is not an URL'
      });
    });

    describe('conflicts', () => {
      test('ogmiosUrl conflicts with ogmiosSrvServiceName', () =>
        runCli('provider', {
          env: { OGMIOS_SRV_SERVICE_NAME: 'test', OGMIOS_URL: ogmiosUrl },
          expectedError: "'OGMIOS_URL' cannot be used with environment variable 'OGMIOS_SRV_SERVICE_NAME'"
        }));
    });
  });

  describe('withPostgresOptionsDbSync', () => {
    describe('postgresDbFile', () => {
      testCli('accepts an existing file', 'provider', {
        args: ['--postgres-db-file-db-sync', 'test/policy_ids'],
        env: { POSTGRES_DB_FILE_DB_SYNC: 'test/policy_ids' },
        expectedArgs: { args: { postgresDbFileDbSync: 'test/policy_ids' } }
      });

      testCli('expects an existing file', 'provider', {
        args: ['--postgres-db-file-db-sync', 'test/file'],
        env: { POSTGRES_DB_FILE_DB_SYNC: 'test/file' },
        expectedError: 'No file exists at test/file'
      });
    });

    describe('postgresPoolMaxDbSync', () => {
      testCli('accepts an integer', 'provider', {
        args: ['--postgres-pool-max-db-sync', '23'],
        env: { POSTGRES_POOL_MAX_DB_SYNC: '23' },
        expectedArgs: { args: { postgresPoolMaxDbSync: 23 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--postgres-pool-max-db-sync', 'test'],
        env: { POSTGRES_POOL_MAX_DB_SYNC: 'test' },
        expectedError: 'Maximum number of clients in the PostgreSQL pool for db sync - "test" is not an integer'
      });
    });

    describe('conflicts', () => {
      test('postgresConnectionStringDbSync conflicts with postgresDbDbSync', () =>
        runCli('provider', {
          env: { POSTGRES_CONNECTION_STRING_DB_SYNC, POSTGRES_DB_DB_SYNC: 'test' },
          expectedError:
            "'POSTGRES_CONNECTION_STRING_DB_SYNC' cannot be used with environment variable 'POSTGRES_DB_DB_SYNC'"
        }));

      test('postgresDbDbSync conflicts with postgresDbFileDbSync', () =>
        runCli('provider', {
          env: { POSTGRES_DB_DB_SYNC: 'test', POSTGRES_DB_FILE_DB_SYNC: 'test/policy_ids' },
          expectedError: "'POSTGRES_DB_DB_SYNC' cannot be used with environment variable 'POSTGRES_DB_FILE_DB_SYNC'"
        }));
    });
  });

  describe('withStakePoolMetadataOptions', () => {
    describe('metadataFetchMode', () => {
      testCli('accepts a valid metadata fetch mode', 'pgboss', {
        args: ['--queues', QUEUES, '--metadata-fetch-mode', 'direct'],
        env: { METADATA_FETCH_MODE: 'direct', QUEUES },
        expectedArgs: { args: { metadataFetchMode: 'direct' } }
      });

      testCli('expects a valid metadata fetch mode', 'pgboss', {
        args: ['--queues', QUEUES, '--metadata-fetch-mode', 'test'],
        env: { METADATA_FETCH_MODE: 'test', QUEUES },
        expectedError: 'Allowed choices are direct, smash'
      });
    });

    describe('smashUrl', () => {
      const smashUrl = 'wss://test/';

      testCli('accepts an URL', 'pgboss', {
        args: ['--queues', QUEUES, '--smash-url', smashUrl],
        env: { QUEUES, SMASH_URL: smashUrl },
        expectedArgs: { args: { smashUrl } }
      });

      testCli('expects an URL', 'pgboss', {
        args: ['--queues', QUEUES, '--smash-url', 'test'],
        env: { QUEUES, SMASH_URL: 'test' },
        expectedError: 'SMASH server api url - "test" is not an URL'
      });
    });

    describe('required combinations', () => {
      test('metadata-fetch-mode smash requires smashUrl', () =>
        runCli('pgboss', {
          env: {
            METADATA_FETCH_MODE: 'smash',
            POSTGRES_CONNECTION_STRING_DB_SYNC,
            POSTGRES_CONNECTION_STRING_STAKE_POOL,
            QUEUES
          },
          expectedOutput: 'pool-metadata requires the smash-url to be set when metadata-fetch-mode is smash',
          notDump
        }));
    });
  });

  describe('blockfrost worker', () => {
    describe('blockfrostApiFile', () => {
      testBlockfrost('accepts any string', 'blockfrost', {
        args: ['--blockfrost-api-file', 'test'],
        env: { BLOCKFROST_API_FILE: 'test' },
        expectedArgs: { args: { blockfrostApiFile: 'test' } }
      });
    });

    describe('blockfrostApiKey', () => {
      testBlockfrost('accepts any string', 'blockfrost', {
        args: ['--blockfrost-api-key', 'test'],
        env: { BLOCKFROST_API_KEY: 'test' },
        expectedArgs: { args: { blockfrostApiKey: 'test' } }
      });
    });

    describe('cacheTtl', () => {
      testBlockfrost('accepts an integer', 'blockfrost', {
        args: ['--cache-ttl', '23'],
        env: { CACHE_TTL: '23' },
        expectedArgs: { args: { cacheTtl: 23 } }
      });

      testBlockfrost('expects an integer', 'blockfrost', {
        args: ['--cache-ttl', 'test'],
        env: { CACHE_TTL: 'test' },
        expectedError: 'TTL of blockfrost cached metrics in minutes - "test" is not an integer'
      });
    });

    describe('createSchema', () => {
      testBlockfrost('accepts a boolean', 'blockfrost', {
        args: ['--create-schema', 'true'],
        env: { CREATE_SCHEMA: 'true' },
        expectedArgs: { args: { createSchema: true } }
      });

      testBlockfrost('expects a boolean', 'blockfrost', {
        args: ['--create-schema', 'test'],
        env: { CREATE_SCHEMA: 'test' },
        expectedError:
          'Blockfrost worker requires a valid create the schema; useful for development program option. Expected: false, true'
      });
    });

    describe('dropSchema', () => {
      testBlockfrost('accepts a boolean', 'blockfrost', {
        args: ['--drop-schema', 'true'],
        env: { DROP_SCHEMA: 'true' },
        expectedArgs: { args: { dropSchema: true } }
      });

      testBlockfrost('expects a boolean', 'blockfrost', {
        args: ['--drop-schema', 'test'],
        env: { DROP_SCHEMA: 'test' },
        expectedError:
          'Blockfrost worker requires a valid drop the schema; useful for development program option. Expected: false, true'
      });
    });

    describe('dryRun', () => {
      testBlockfrost('accepts a boolean', 'blockfrost', {
        args: ['--dry-run', 'true'],
        env: { DRY_RUN: 'true' },
        expectedArgs: { args: { dryRun: true } }
      });

      testBlockfrost('expects a boolean', 'blockfrost', {
        args: ['--dry-run', 'test'],
        env: { DRY_RUN: 'test' },
        expectedError:
          'Blockfrost worker requires a valid dry run; useful for tests program option. Expected: false, true'
      });
    });

    describe('network', () => {
      testCli('accepts a valid network', 'blockfrost', {
        args: ['--network', 'mainnet'],
        env: { NETWORK: 'mainnet' },
        expectedArgs: { args: { network: 'mainnet' } }
      });

      testCli('expects a valid network', 'blockfrost', {
        args: ['--network', 'test'],
        env: { NETWORK: 'test' },
        expectedError: 'Unknown network: test'
      });

      testCli('is mandatory', 'blockfrost', { expectedError: "required option '--network <network>' not specified" });
    });

    describe('scanInterval', () => {
      testBlockfrost('accepts an integer', 'blockfrost', {
        args: ['--scan-interval', '23'],
        env: { SCAN_INTERVAL: '23' },
        expectedArgs: { args: { scanInterval: 23 } }
      });

      testBlockfrost('expects an integer', 'blockfrost', {
        args: ['--scan-interval', 'test'],
        env: { SCAN_INTERVAL: 'test' },
        expectedError: 'interval between a scan and the next one in minutes - "test" is not an integer'
      });
    });

    describe('conflicts', () => {
      test('blockfrostApiFile conflicts with blockfrostApiKey', () =>
        runCli('blockfrost', {
          env: { BLOCKFROST_API_FILE: 'test', BLOCKFROST_API_KEY: 'test', NETWORK: 'mainnet' },
          expectedError: "'BLOCKFROST_API_FILE' cannot be used with environment variable 'BLOCKFROST_API_KEY'"
        }));
    });

    describe('required combinations', () => {
      test('requires blockfrostApiFile or blockfrostApiKey', () =>
        runCli('blockfrost', {
          env: { NETWORK: 'mainnet' },
          expectedError:
            'Blockfrost worker requires the Blockfrost API Key file path or Blockfrost API Key program option',
          notDump
        }));

      test('requires DB connection config', () =>
        runCli('blockfrost', {
          env: { BLOCKFROST_API_KEY: 'test', NETWORK: 'mainnet' },
          expectedError:
            'Blockfrost worker requires the PostgreSQL Connection string or Postgres SRV service name, db, user and password program option',
          notDump
        }));
    });
  });

  describe('pg-boss worker', () => {
    describe('parallelJobs', () => {
      testPgBoss('accepts an integer', 'pgboss', {
        args: ['--parallel-jobs', '23'],
        env: { PARALLEL_JOBS: '23' },
        expectedArgs: { args: { parallelJobs: 23 } }
      });

      testPgBoss('expects an integer', 'pgboss', {
        args: ['--parallel-jobs', 'test'],
        env: { PARALLEL_JOBS: 'test' },
        expectedError: 'Parallel jobs to run - "test" is not an integer'
      });
    });

    describe('queues', () => {
      testCli('accepts an array of valid queues', 'pgboss', {
        args: ['--queues', QUEUES],
        env: { QUEUES },
        expectedArgs: { args: { queues } }
      });

      testCli('expects an array of valid queues', 'pgboss', {
        args: ['--queues', 'test'],
        env: { QUEUES: 'test' },
        expectedError: "Unknown queue name: 'test'"
      });

      testCli('is mandatory', 'pgboss', { expectedError: "required option '--queues <queues>' not specified" });
    });

    describe('schedules', () => {
      testPgBoss('accepts a valid schedule file', 'pgboss', {
        args: ['--schedules', 'environments/schedules.json'],
        env: { SCHEDULES: 'environments/schedules.json' },
        expectedArgs: {
          args: { schedules: [{ cron: '0 * * * *', queue: 'pool-delist-schedule', scheduleOptions: {} }] }
        }
      });

      testPgBoss('expects a file', 'pgboss', {
        args: ['--schedules', 'unknown'],
        env: { SCHEDULES: 'unknown' },
        expectedError: 'File does not exist: unknown'
      });

      testPgBoss('expects a valid schedule file', 'pgboss', {
        args: ['--schedules', 'test/policy_ids'],
        env: { SCHEDULES: 'test/policy_ids' },
        expectedError: 'Failed to parse the schedule config from file: test/policy_ids'
      });
    });

    describe('required combinations', () => {
      test('requires DB connection config', () =>
        runCli('pgboss', {
          env: { QUEUES },
          expectedError:
            'pg-boss-worker requires the postgresConnectionString or postgresSrvServiceName or postgresUser or postgresDb or postgresPassword program option',
          notDump
        }));

      test('pool-metrics requires stakePoolProviderUrl', () =>
        runCli('pgboss', {
          env: { POSTGRES_CONNECTION_STRING_DB_SYNC, POSTGRES_CONNECTION_STRING_STAKE_POOL, QUEUES },
          expectedOutput: 'pool-metrics requires the stake-pool provider URL program option',
          notDump
        }));

      test('pool-rewards requires networkInfoProviderUrl', () =>
        runCli('pgboss', {
          env: {
            POSTGRES_CONNECTION_STRING_DB_SYNC,
            POSTGRES_CONNECTION_STRING_STAKE_POOL,
            QUEUES,
            STAKE_POOL_PROVIDER_URL: 'http://test/'
          },
          expectedOutput: 'pool-rewards requires the network-info provider URL program option',
          notDump
        }));
    });
  });

  describe('projector', () => {
    describe('blocksBufferLength', () => {
      testCli('accepts an integer', 'projector', {
        args: ['--blocks-buffer-length', '23'],
        env: { BLOCKS_BUFFER_LENGTH: '23' },
        expectedArgs: { args: { blocksBufferLength: 23 } }
      });

      testCli('expects an integer', 'projector', {
        args: ['--blocks-buffer-length', 'test'],
        env: { BLOCKS_BUFFER_LENGTH: 'test' },
        expectedError: 'Chain sync event (blocks) buffer length - "test" is not an integer'
      });
    });

    describe('dropSchema', () => {
      testCli('accepts a boolean', 'projector', {
        args: ['--drop-schema', 't'],
        env: { DROP_SCHEMA: 't' },
        expectedArgs: { args: { dropSchema: true } }
      });

      testCli('expects a boolean', 'projector', {
        args: ['--drop-schema', 'test'],
        env: { DROP_SCHEMA: 'test' },
        expectedError: 'requires a valid Drop and recreate database schema to project from origin'
      });
    });

    describe('dryRun', () => {
      testCli('accepts a boolean', 'projector', {
        args: ['--dry-run', 't'],
        env: { DRY_RUN: 't' },
        expectedArgs: { args: { dryRun: true } }
      });

      testCli('expects a boolean', 'projector', {
        args: ['--dry-run', 'test'],
        env: { DRY_RUN: 'test' },
        expectedError: 'requires a valid Initialize the projection, but do not start it'
      });
    });

    describe('exitAtBlockNo', () => {
      testCli('accepts an integer', 'projector', {
        args: ['--exit-at-block-no', '23'],
        env: { EXIT_AT_BLOCK_NO: '23' },
        expectedArgs: { args: { exitAtBlockNo: 23 } }
      });

      testCli('expects an integer', 'projector', {
        args: ['--exit-at-block-no', 'test'],
        env: { EXIT_AT_BLOCK_NO: 'test' },
        expectedError: 'Exit after processing this block. Intended for benchmark testing - "test" is not an integer'
      });

      test('defaults to 0', () => runCli('projector', { expectedArgs: { args: { exitAtBlockNo: 0 } } }));
    });

    describe('metadataJobRetryDelay', () => {
      testCli('accepts an integer', 'projector', {
        args: ['--metadata-job-retry-delay', '23'],
        env: { METADATA_JOB_RETRY_DELAY: '23' },
        expectedArgs: { args: { metadataJobRetryDelay: 23 } }
      });

      testCli('expects an integer', 'projector', {
        args: ['--metadata-job-retry-delay', 'test'],
        env: { METADATA_JOB_RETRY_DELAY: 'test' },
        expectedError: 'Retry delay for metadata fetch job in seconds - "test" is not an integer'
      });
    });

    describe('poolsMetricsInterval', () => {
      testCli('accepts an integer', 'projector', {
        args: ['--pools-metrics-interval', '23'],
        env: { POOLS_METRICS_INTERVAL: '23' },
        expectedArgs: { args: { poolsMetricsInterval: 23 } }
      });

      testCli('expects an integer', 'projector', {
        args: ['--pools-metrics-interval', 'test'],
        env: { POOLS_METRICS_INTERVAL: 'test' },
        expectedError:
          'Interval in number of blocks between two stake pools metrics jobs to update all metrics - "test" is not an integer'
      });
    });

    describe('poolsMetricsOutdatedInterval', () => {
      testCli('accepts an integer', 'projector', {
        args: ['--pools-metrics-outdated-interval', '23'],
        env: { POOLS_METRICS_OUTDATED_INTERVAL: '23' },
        expectedArgs: { args: { poolsMetricsOutdatedInterval: 23 } }
      });

      testCli('expects an integer', 'projector', {
        args: ['--pools-metrics-outdated-interval', 'test'],
        env: { POOLS_METRICS_OUTDATED_INTERVAL: 'test' },
        expectedError:
          'Interval in number of blocks between two stake pools metrics jobs to update only outdated metrics - "test" is not an integer'
      });
    });

    describe('projectionNames', () => {
      const projectionNames = ['asset', 'handle', 'stake-pool'];
      const goodNames = projectionNames.join(',');
      const badNames = 'asset,unknown';
      const expectedError = 'Unknown projection name "unknown"';

      testCli('accepts an array of projections', 'projector', {
        args: ['--projection-names', goodNames],
        env: { PROJECTION_NAMES: goodNames },
        expectedArgs: { args: { projectionNames } }
      });

      testCli('expects an array of projections', 'projector', {
        args: ['--projection-names', badNames],
        env: { PROJECTION_NAMES: badNames },
        expectedError
      });

      test('arg - accepts an array of projections', () =>
        runCli('projector', { args: [goodNames], expectedArgs: { projectionNames } }));

      test('arg - expects an array of projections', () => runCli('projector', { args: [badNames], expectedError }));
    });

    describe('synchronize', () => {
      testCli('accepts a boolean', 'projector', {
        args: ['--synchronize', 't'],
        env: { SYNCHRONIZE: 't' },
        expectedArgs: { args: { synchronize: true } }
      });

      testCli('expects a boolean', 'projector', {
        args: ['--synchronize', 'test'],
        env: { SYNCHRONIZE: 'test' },
        expectedError: 'Projector requires a valid Synchronize the schema from the models'
      });
    });

    describe('required combinations', () => {
      test('handle projection requires handlePolicyIds or handlePolicyIdsFile', () =>
        runCli('projector', {
          env: { PROJECTION_NAMES: 'handle', QUEUES },
          expectedError: 'handle requires the Handle policy Ids or Handle policy Ids file program option',
          notDump
        }));
    });
  });

  describe('provider server', () => {
    describe('allowedOrigins', () => {
      const allowedOrigins = ['origin 1', 'test origin', 'origin n'];
      const origins = allowedOrigins.join(',');

      testCli('accepts an array of origins', 'provider', {
        args: ['--allowed-origins', origins],
        env: { ALLOWED_ORIGINS: origins },
        expectedArgs: { args: { allowedOrigins } }
      });
    });

    describe('assetCacheTtl', () => {
      testCli('accepts an integer between the edges', 'provider', {
        args: ['--asset-cache-ttl', '123'],
        env: { ASSET_CACHE_TTL: '123' },
        expectedArgs: { args: { assetCacheTtl: 123 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--asset-cache-ttl', 'test'],
        env: { ASSET_CACHE_TTL: 'test' },
        expectedError: 'Asset info and NFT Metadata cache TTL in seconds (600 by default) - "test" is not an integer'
      });

      testCli('expects an integer between the edges', 'provider', {
        args: ['--asset-cache-ttl', '23'],
        env: { ASSET_CACHE_TTL: '23' },
        expectedError:
          'Asset info and NFT Metadata cache TTL in seconds (600 by default) - 23 must be between 60 and 172800'
      });
    });

    describe('cardanoNodeConfigPath', () => {
      const cardanoNodeConfigPath = 'path/to/config';

      testCli('accepts a path', 'provider', {
        args: ['--cardano-node-config-path', cardanoNodeConfigPath],
        env: { CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath },
        expectedArgs: { args: { cardanoNodeConfigPath } }
      });
    });

    describe('dbCacheTtl', () => {
      testCli('accepts an integer between the edges', 'provider', {
        args: ['--db-cache-ttl', '123'],
        env: { DB_CACHE_TTL: '123' },
        expectedArgs: { args: { dbCacheTtl: 123 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--db-cache-ttl', 'test'],
        env: { DB_CACHE_TTL: 'test' },
        expectedError:
          'Cache TTL in seconds between 60 and 172800 (two days), an option for database related operations - "test" is not an integer'
      });

      testCli('expects an integer between the edges', 'provider', {
        args: ['--db-cache-ttl', '23'],
        env: { DB_CACHE_TTL: '23' },
        expectedError:
          'Cache TTL in seconds between 60 and 172800 (two days), an option for database related operations - 23 must be between 60 and 172800'
      });
    });

    describe('disableDbCache', () => {
      testCli('accepts a boolean', 'provider', {
        args: ['--disable-db-cache', 'true'],
        env: { DISABLE_DB_CACHE: 'true' },
        expectedArgs: { args: { disableDbCache: true } }
      });

      testCli('expects a boolean', 'provider', {
        args: ['--disable-db-cache', 'test'],
        env: { DISABLE_DB_CACHE: 'test' },
        expectedError: 'Provider server requires a valid Disable DB cache program option. Expected: false, true'
      });
    });

    describe('disableStakePoolMetricApy', () => {
      testCli('accepts a boolean', 'provider', {
        args: ['--disable-stake-pool-metric-apy', 'true'],
        env: { DISABLE_STAKE_POOL_METRIC_APY: 'true' },
        expectedArgs: { args: { disableStakePoolMetricApy: true } }
      });

      testCli('expects a boolean', 'provider', {
        args: ['--disable-stake-pool-metric-apy', 'test'],
        env: { DISABLE_STAKE_POOL_METRIC_APY: 'test' },
        expectedError:
          'Provider server requires a valid Omit this metric for improved query performance program option. Expected: false, true'
      });
    });

    describe('epochPollInterval', () => {
      testCli('accepts an integer', 'provider', {
        args: ['--epoch-poll-interval', '23'],
        env: { EPOCH_POLL_INTERVAL: '23' },
        expectedArgs: { args: { epochPollInterval: 23 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--epoch-poll-interval', 'test'],
        env: { EPOCH_POLL_INTERVAL: 'test' },
        expectedError: 'Epoch poll interval - "test" is not an integer'
      });
    });

    describe('fuzzyOptions', () => {
      const FUZZY_OPTIONS =
        '{"distance":100,"location":0,"threshold":0.4,"weights":{"description":1,"homepage":2,"name":3,"poolId":4,"ticker":4}}';

      testCli('has a default value', 'provider', {
        expectedArgs: { args: { fuzzyOptions: DEFAULT_FUZZY_SEARCH_OPTIONS } }
      });

      testCli('accepts a valid options object', 'provider', {
        args: ['--fuzzy-options', FUZZY_OPTIONS],
        env: { FUZZY_OPTIONS },
        expectedArgs: { args: { fuzzyOptions: DEFAULT_FUZZY_SEARCH_OPTIONS } }
      });

      testCli('expects an object', 'provider', {
        args: ['--fuzzy-options', 'test'],
        env: { FUZZY_OPTIONS: 'test' },
        expectedError: 'TypeError: expected.join is not a function'
      });
    });

    describe('handleProviderServerUrl', () => {
      testCli('accepts any string', 'provider', {
        args: ['--handle-provider-server-url', 'test'],
        env: { HANDLE_PROVIDER_SERVER_URL: 'test' },
        expectedArgs: { args: { handleProviderServerUrl: 'test' } }
      });
    });

    describe('healthCheckCacheTtl', () => {
      testCli('accepts an integer between the edges', 'provider', {
        args: ['--health-check-cache-ttl', '23'],
        env: { HEALTH_CHECK_CACHE_TTL: '23' },
        expectedArgs: { args: { healthCheckCacheTtl: 23 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--health-check-cache-ttl', 'test'],
        env: { HEALTH_CHECK_CACHE_TTL: 'test' },
        expectedError: 'Health check cache TTL in seconds between 1 and 10 - "test" is not an integer'
      });

      testCli('expects an integer between the edges', 'provider', {
        args: ['--health-check-cache-ttl', '123'],
        env: { HEALTH_CHECK_CACHE_TTL: '123' },
        expectedError: 'Health check cache TTL in seconds between 1 and 10 - 123 must be between 1 and 120'
      });
    });

    describe('overrideFuzzyOptions', () => {
      testCli('accepts a boolean', 'provider', {
        args: ['--override-fuzzy-options', 'true'],
        env: { OVERRIDE_FUZZY_OPTIONS: 'true' },
        expectedArgs: { args: { overrideFuzzyOptions: true } }
      });

      testCli('expects a boolean', 'provider', {
        args: ['--override-fuzzy-options', 'test'],
        env: { OVERRIDE_FUZZY_OPTIONS: 'test' },
        expectedError:
          'Provider server requires a valid Allows the override of fuzzyOptions through queryStakePools call program option. Expected: false, true'
      });
    });

    describe('paginationPageSizeLimit', () => {
      testCli('accepts an integer between the edges', 'provider', {
        args: ['--pagination-page-size-limit', '23'],
        env: { PAGINATION_PAGE_SIZE_LIMIT: '23' },
        expectedArgs: { args: { paginationPageSizeLimit: 23 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--health-check-cache-ttl', 'test'],
        env: { HEALTH_CHECK_CACHE_TTL: 'test' },
        expectedError: 'Health check cache TTL in seconds between 1 and 10 - "test" is not an integer'
      });
    });

    describe('submitApiUrl', () => {
      const submitApiUrl = 'https://test/';

      testCli('accepts an URL', 'provider', {
        args: ['--submit-api-url', submitApiUrl],
        env: { SUBMIT_API_URL: submitApiUrl },
        expectedArgs: { args: { submitApiUrl } }
      });

      testCli('expects an URL', 'provider', {
        args: ['--submit-api-url', 'test'],
        env: { SUBMIT_API_URL: 'test' },
        expectedError: 'cardano-submit-api URL - "test" is not an URL'
      });
    });

    describe('tokenMetadataCacheTtl', () => {
      testCli('accepts an integer between the edges', 'provider', {
        args: ['--token-metadata-cache-ttl', '123'],
        env: { TOKEN_METADATA_CACHE_TTL: '123' },
        expectedArgs: { args: { tokenMetadataCacheTtl: 123 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--token-metadata-cache-ttl', 'test'],
        env: { TOKEN_METADATA_CACHE_TTL: 'test' },
        expectedError: 'Token Metadata API cache TTL in seconds - "test" is not an integer'
      });

      testCli('expects an integer between the edges', 'provider', {
        args: ['--token-metadata-cache-ttl', '23'],
        env: { TOKEN_METADATA_CACHE_TTL: '23' },
        expectedError: 'Token Metadata API cache TTL in seconds - 23 must be between 60 and 172800'
      });
    });

    describe('tokenMetadataRequestTimeout', () => {
      testCli('accepts an integer', 'provider', {
        args: ['--token-metadata-request-timeout', '23000'],
        env: { TOKEN_METADATA_REQUEST_TIMEOUT: '23000' },
        expectedArgs: { args: { tokenMetadataRequestTimeout: 23_000 } }
      });

      testCli('expects an integer', 'provider', {
        args: ['--token-metadata-request-timeout', 'test'],
        env: { TOKEN_METADATA_REQUEST_TIMEOUT: 'test' },
        expectedError: 'Token Metadata request timeout in milliseconds - "test" is not an integer'
      });
    });

    describe('tokenMetadataServerUrl', () => {
      const tokenMetadataServerUrl = 'https://test/';

      testCli('accepts an URL', 'provider', {
        args: ['--token-metadata-server-url', tokenMetadataServerUrl],
        env: { TOKEN_METADATA_SERVER_URL: tokenMetadataServerUrl },
        expectedArgs: { args: { tokenMetadataServerUrl } }
      });

      testCli('expects an URL', 'provider', {
        args: ['--token-metadata-server-url', 'test'],
        env: { TOKEN_METADATA_SERVER_URL: 'test' },
        expectedError: 'Token Metadata API server URL - "test" is not an URL'
      });
    });

    describe('serviceNames', () => {
      const serviceNames = ['asset', 'handle', 'stake-pool'];
      const goodNames = serviceNames.join(',');
      const badNames = 'asset,unknown';
      const expectedError = 'Unknown service name "unknown"';

      testCli('accepts an array of services', 'provider', {
        args: ['--service-names', goodNames],
        env: { SERVICE_NAMES: goodNames },
        expectedArgs: { args: { serviceNames } }
      });

      testCli('expects an array of services', 'provider', {
        args: ['--service-names', badNames],
        env: { SERVICE_NAMES: badNames },
        expectedError
      });

      test('arg - accepts an array of services', () =>
        runCli('provider', { args: [goodNames], expectedArgs: { serviceNames } }));

      test('arg - expects an array of services', () => runCli('provider', { args: [badNames], expectedError }));
    });

    describe('submitValidateHandles', () => {
      testCli('accepts a boolean', 'provider', {
        args: ['--submit-validate-handles', 'true'],
        env: { SUBMIT_VALIDATE_HANDLES: 'true' },
        expectedArgs: { args: { submitValidateHandles: true } }
      });

      testCli('expects a boolean', 'provider', {
        args: ['--submit-validate-handles', 'test'],
        env: { SUBMIT_VALIDATE_HANDLES: 'test' },
        expectedError:
          'Provider server requires a valid Validate handle resolutions before submitting transactions. Requires handle provider options (USE_KORA_LABS or POSTGRES options with HANDLE suffix). program option. Expected: false, true'
      });
    });

    describe('useBlockfrost', () => {
      testCli('accepts a boolean', 'provider', {
        args: ['--use-blockfrost', 'true'],
        env: { USE_BLOCKFROST: 'true' },
        expectedArgs: { args: { useBlockfrost: true } }
      });

      testCli('expects a boolean', 'provider', {
        args: ['--use-blockfrost', 'test'],
        env: { USE_BLOCKFROST: 'test' },
        expectedError:
          'Provider server requires a valid Enables Blockfrost cached data DB program option. Expected: false, true'
      });
    });

    describe('useKoraLabs', () => {
      testCli('accepts a boolean', 'provider', {
        args: ['--use-kora-labs', 'true'],
        env: { USE_KORA_LABS: 'true' },
        expectedArgs: { args: { useKoraLabs: true } }
      });

      testCli('expects a boolean', 'provider', {
        args: ['--use-kora-labs', 'test'],
        env: { USE_KORA_LABS: 'test' },
        expectedError:
          'Provider server requires a valid Use the KoraLabs handle provider program option. Expected: false, true'
      });
    });

    describe('useSubmitApi', () => {
      testCli('accepts a boolean', 'provider', {
        args: ['--use-submit-api', 'true'],
        env: { USE_SUBMIT_API: 'true' },
        expectedArgs: { args: { useSubmitApi: true } }
      });

      testCli('expects a boolean', 'provider', {
        args: ['--use-submit-api', 'test'],
        env: { USE_SUBMIT_API: 'test' },
        expectedError:
          'Provider server requires a valid Use cardano-submit-api provider program option. Expected: false, true'
      });
    });

    describe('useTypeormAssetProvider', () => {
      testCli('accepts a boolean', 'provider', {
        args: ['--use-typeorm-asset-provider', 'true'],
        env: { USE_TYPEORM_ASSET_PROVIDER: 'true' },
        expectedArgs: { args: { useTypeormAssetProvider: true } }
      });

      testCli('expects a boolean', 'provider', {
        args: ['--use-typeorm-asset-provider', 'test'],
        env: { USE_TYPEORM_ASSET_PROVIDER: 'test' },
        expectedError:
          'Provider server requires a valid Use the TypeORM Asset Provider (default is db-sync) program option. Expected: false, true'
      });
    });

    describe('useTypeormStakePoolProvider', () => {
      testCli('accepts a boolean', 'provider', {
        args: ['--use-typeorm-stake-pool-provider', 'true'],
        env: { USE_TYPEORM_STAKE_POOL_PROVIDER: 'true' },
        expectedArgs: { args: { useTypeormStakePoolProvider: true } }
      });

      testCli('expects a boolean', 'provider', {
        args: ['--use-typeorm-stake-pool-provider', 'test'],
        env: { USE_TYPEORM_STAKE_POOL_PROVIDER: 'test' },
        expectedError:
          'Provider server requires a valid Enables the TypeORM Stake Pool Provider program option. Expected: false, true'
      });
    });

    describe('required combinations', () => {
      test('DB dependant services require DB connection configuration', () =>
        runCli('provider', {
          env: { SERVICE_NAMES: 'network-info' },
          expectedError:
            'network-info requires the PostgreSQL Connection string or Postgres SRV service name, db, user and password program option',
          notDump
        }));

      test('cardano configuration dependant services require cardanoNodeConfigPath', () =>
        runCli('provider', {
          env: { POSTGRES_CONNECTION_STRING_DB_SYNC, SERVICE_NAMES: 'network-info' },
          expectedError: 'network-info requires the Cardano node config path program option',
          notDump
        }));
    });
  });
});
