/* eslint-disable sonarjs/cognitive-complexity */
/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable max-len */
/* eslint-disable @typescript-eslint/no-explicit-any */
import { Asset } from '@cardano-sdk/core';
import { AssetData, AssetFixtureBuilder, AssetWith } from './Asset/fixtures/FixtureBuilder';
import { BAD_CONNECTION_URL } from './TxSubmit/rabbitmq/utils';
import { ChildProcess, fork } from 'child_process';
import { LedgerTipModel, findLedgerTip } from '../src/util/DbSyncProvider';
import { Ogmios } from '@cardano-sdk/ogmios';
import { Pool } from 'pg';
import { RabbitMQContainer } from './TxSubmit/rabbitmq/docker';
import { ServerMetadata, ServiceNames } from '../src';
import { createHealthyMockOgmiosServer, createUnhealthyMockOgmiosServer, ogmiosServerReady, serverReady } from './util';
import { createLogger } from '@cardano-sdk/util-dev';
import { fromSerializableObject } from '@cardano-sdk/util';
import { getRandomPort } from 'get-port-please';
import { healthCheckResponseMock } from '../../core/test/CardanoNode/mocks';
import { listenPromise, serverClosePromise } from '../src/util';
import { mockTokenRegistry } from './Asset/CardanoTokenRegistry.test';
import axios, { AxiosError } from 'axios';
import http from 'http';
import path from 'path';

jest.setTimeout(90_000);

const DNS_SERVER_NOT_REACHABLE_ERROR = 'querySrv ENOTFOUND';
const CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE = 'cannot be used with option';
const CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE = 'cannot be used with environment variable';
const METRICS_ENDPOINT_LABEL_RESPONSE = 'http_request_duration_seconds duration histogram of http responses';

const exePath = path.join(__dirname, '..', 'dist', 'cjs', 'cli.js');
const logger = createLogger({ env: process.env.TL_LEVEL ? process.env : { ...process.env, TL_LEVEL: 'error' } });

const assertServiceHealthy = async (
  apiUrl: string,
  serviceName: ServiceNames,
  lastBlock: LedgerTipModel,
  withTip = true,
  usedQueue?: boolean
) => {
  await serverReady(apiUrl);
  const headers = { 'Content-Type': 'application/json' };
  const res = await axios.post(`${apiUrl}/${serviceName}/health`, { headers });

  const healthCheckResponse = usedQueue
    ? { ok: true }
    : healthCheckResponseMock({
        projectedTip: {
          blockNo: lastBlock!.block_no,
          hash: lastBlock!.hash.toString('hex'),
          slot: Number(lastBlock!.slot_no)
        },
        withTip
      });

  expect(res.status).toBe(200);
  expect(res.data).toEqual(healthCheckResponse);
};

const assertMetricsEndpoint = async (apiUrl: string, assertFound: boolean) => {
  expect.assertions(1);
  await serverReady(apiUrl);
  const headers = { 'Content-Type': 'application/json' };
  try {
    const res = await axios.get(`${apiUrl}/metrics`, { headers });
    expect(res.data.toString().includes(METRICS_ENDPOINT_LABEL_RESPONSE)).toEqual(assertFound);
  } catch (error) {
    expect((error as AxiosError).response?.status).toBe(404);
  }
};

const assertMetaEndpoint = async (apiUrl: string, dataMatch: any) => {
  expect.assertions(1);
  await serverReady(apiUrl);
  const headers = { 'Content-Type': 'application/json' };
  try {
    const res = await axios.get(`${apiUrl}/meta`, { headers });
    expect(res.data).toMatchShapeOf(dataMatch);
  } catch (error) {
    expect((error as AxiosError).response?.status).toBe(404);
  }
};

const assertStakePoolApyInResponse = async (apiUrl: string, assertFound: boolean) => {
  expect.assertions(1);
  await serverReady(apiUrl);
  const headers = { 'Content-Type': 'application/json' };
  const res = await axios.post(`${apiUrl}/stake-pool/search`, { headers, pagination: { limit: 1, startAt: 0 } });
  const apy = res.data.pageResults[0].metrics.apy;
  if (assertFound) {
    expect(typeof apy).toBe('number');
  } else {
    expect(apy.__type).toBe('undefined');
  }
};

type CallCliAndAssertExitArgs = {
  args?: string[];
  dataMatchOnError?: string;
  env?: NodeJS.ProcessEnv;
};

const baseArgs = ['start-provider-server', '--logger-min-severity', 'error'];

const withLogging = (proc: ChildProcess, expectingExceptions = false): ChildProcess => {
  const methodOnFailure = expectingExceptions ? 'debug' : 'error';
  proc.on('error', (error) => logger[methodOnFailure](error));
  proc.stderr!.on('data', (data) => logger[methodOnFailure](data.toString()));
  proc.stdout!.on('data', (data) => logger.info(data.toString()));
  return proc;
};

const callCliAndAssertExit = (
  { args = [], dataMatchOnError, env = {} }: CallCliAndAssertExitArgs,
  done: jest.DoneCallback
) => {
  const spy = jest.fn();
  expect.assertions(dataMatchOnError ? 3 : 2);
  const proc = withLogging(
    fork(exePath, [...baseArgs, ...args], {
      env,
      stdio: 'pipe'
    }),
    true
  );
  const chunks: string[] = [];
  proc.stderr!.on('data', (data) => {
    spy();
    chunks.push(data.toString());
  });
  proc.on('exit', (code) => {
    try {
      expect(code).toBe(1);
      expect(spy).toHaveBeenCalled();
      if (dataMatchOnError) expect(chunks.join('')).toContain(dataMatchOnError);
      done();
    } catch (error) {
      done(error);
    }
  });
};

describe('CLI', () => {
  const container = new RabbitMQContainer();
  let db: Pool;
  let fixtureBuilder: AssetFixtureBuilder;
  let lastBlock: LedgerTipModel;

  describe('start-provider-server', () => {
    let apiPort: number;
    let apiUrl: string;
    let ogmiosServer: http.Server;
    let proc: ChildProcess;
    let rabbitmqUrl: URL;

    beforeAll(async () => {
      ({ rabbitmqUrl } = await container.load());
      db = new Pool({ connectionString: process.env.POSTGRES_CONNECTION_STRING });
      fixtureBuilder = new AssetFixtureBuilder(db, logger);
      lastBlock = (await db!.query<LedgerTipModel>(findLedgerTip)).rows[0];
    });

    beforeEach(async () => {
      apiPort = await getRandomPort();
      apiUrl = `http://localhost:${apiPort}`;
    });

    afterEach(() => {
      if (proc !== undefined) proc.kill();
      if (ogmiosServer !== undefined) {
        return serverClosePromise(ogmiosServer);
      }
    });

    it('CLI version', (done) => {
      proc = withLogging(
        fork(exePath, ['--version'], {
          stdio: 'pipe'
        })
      );
      proc.stdout!.on('data', (data) => {
        expect(data.toString()).toBeDefined();
      });
      proc.stdout?.on('end', () => {
        done();
      });
    });

    describe('cli:start-provider-server', () => {
      let postgresConnectionString: string;
      let ogmiosPort: Ogmios.ConnectionConfig['port'];
      let ogmiosConnection: Ogmios.Connection;
      let cardanoNodeConfigPath: string;
      let dbCacheTtl: string;
      let postgresSrvServiceName: string;
      let postgresDb: string;
      let postgresUser: string;
      let postgresPassword: string;
      let postgresDbFile: string;
      let postgresUserFile: string;
      let postgresPasswordFile: string;
      let postgresSslCaFile: string;
      let postgresHost: string;
      let postgresPort: string;
      let ogmiosSrvServiceName: string;
      let rabbitmqSrvServiceName: string;

      beforeAll(async () => {
        ogmiosPort = await getRandomPort();
        ogmiosConnection = Ogmios.createConnectionObject({ port: ogmiosPort });
        postgresConnectionString = process.env.POSTGRES_CONNECTION_STRING!;
        cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
        postgresSrvServiceName = process.env.POSTGRES_SRV_SERVICE_NAME!;
        postgresDb = process.env.POSTGRES_DB!;
        postgresDbFile = process.env.POSTGRES_DB_FILE!;
        postgresUser = process.env.POSTGRES_USER!;
        postgresUserFile = process.env.POSTGRES_USER_FILE!;
        postgresPassword = process.env.POSTGRES_PASSWORD!;
        postgresPasswordFile = process.env.POSTGRES_PASSWORD_FILE!;
        postgresHost = process.env.POSTGRES_HOST!;
        postgresPort = process.env.POSTGRES_PORT!;
        postgresSslCaFile = process.env.POSTGRES_SSL_CA_FILE!;
        ogmiosSrvServiceName = process.env.OGMIOS_SRV_SERVICE_NAME!;
        rabbitmqSrvServiceName = process.env.RABBITMQ_SRV_SERVICE_NAME!;
        dbCacheTtl = process.env.DB_CACHE_TTL!;
      });

      describe('with healthy internal providers', () => {
        describe('valid configuration', () => {
          beforeEach(async () => {
            ogmiosServer = createHealthyMockOgmiosServer();
            await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
            await ogmiosServerReady(ogmiosConnection);
          });

          it('exposes a HTTP server at the configured URL with all services attached when using CLI options', async () => {
            proc = withLogging(
              fork(
                exePath,
                [
                  ...baseArgs,
                  '--api-url',
                  apiUrl,
                  '--enable-metrics',
                  'true',
                  '--postgres-connection-string',
                  postgresConnectionString,
                  '--ogmios-url',
                  ogmiosConnection.address.webSocket,
                  '--cardano-node-config-path',
                  cardanoNodeConfigPath,
                  '--db-cache-ttl',
                  dbCacheTtl,
                  ServiceNames.Asset,
                  ServiceNames.ChainHistory,
                  ServiceNames.NetworkInfo,
                  ServiceNames.StakePool,
                  ServiceNames.TxSubmit,
                  ServiceNames.Utxo,
                  ServiceNames.Rewards
                ],
                { env: {}, stdio: 'pipe' }
              )
            );

            await assertServiceHealthy(apiUrl, ServiceNames.Asset, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.ChainHistory, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.NetworkInfo, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.StakePool, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit, lastBlock, false, false);
            await assertServiceHealthy(apiUrl, ServiceNames.Utxo, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.Rewards, lastBlock);
          });

          it('exposes a HTTP server at the configured URL with all services attached when using env variables', async () => {
            proc = withLogging(
              fork(exePath, ['start-provider-server'], {
                env: {
                  API_URL: apiUrl,
                  CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
                  DB_CACHE_TTL: dbCacheTtl,
                  ENABLE_METRICS: 'true',
                  LOGGER_MIN_SEVERITY: 'error',
                  OGMIOS_URL: ogmiosConnection.address.webSocket,
                  POSTGRES_CONNECTION_STRING: postgresConnectionString,
                  SERVICE_NAMES: `${ServiceNames.Asset},${ServiceNames.ChainHistory},${ServiceNames.NetworkInfo},${ServiceNames.StakePool},${ServiceNames.TxSubmit},${ServiceNames.Utxo},${ServiceNames.Rewards}`
                },
                stdio: 'pipe'
              })
            );

            await assertServiceHealthy(apiUrl, ServiceNames.Asset, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.ChainHistory, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.NetworkInfo, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.StakePool, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit, lastBlock, false, false);
            await assertServiceHealthy(apiUrl, ServiceNames.Utxo, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.Rewards, lastBlock);
          });

          it('exposes a HTTP server with /metrics endpoint using CLI options', async () => {
            proc = withLogging(
              fork(
                exePath,
                [
                  ...baseArgs,
                  '--api-url',
                  apiUrl,
                  '--enable-metrics',
                  'true',
                  '--postgres-connection-string',
                  postgresConnectionString,
                  '--ogmios-url',
                  ogmiosConnection.address.webSocket,
                  '--cardano-node-config-path',
                  cardanoNodeConfigPath,
                  '--db-cache-ttl',
                  dbCacheTtl,
                  ServiceNames.Asset,
                  ServiceNames.ChainHistory,
                  ServiceNames.NetworkInfo,
                  ServiceNames.StakePool,
                  ServiceNames.TxSubmit,
                  ServiceNames.Utxo,
                  ServiceNames.Rewards
                ],
                { env: {}, stdio: 'pipe' }
              )
            );

            await assertMetricsEndpoint(apiUrl, true);
          });

          it('exposes a HTTP server with /metrics endpoint using env variables', async () => {
            proc = withLogging(
              fork(exePath, ['start-provider-server'], {
                env: {
                  API_URL: apiUrl,
                  CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
                  DB_CACHE_TTL: dbCacheTtl,
                  ENABLE_METRICS: 'true',
                  LOGGER_MIN_SEVERITY: 'error',
                  OGMIOS_URL: ogmiosConnection.address.webSocket,
                  POSTGRES_CONNECTION_STRING: postgresConnectionString,
                  SERVICE_NAMES: `${ServiceNames.Asset},${ServiceNames.ChainHistory},${ServiceNames.NetworkInfo},${ServiceNames.StakePool},${ServiceNames.TxSubmit},${ServiceNames.Utxo},${ServiceNames.Rewards}`
                },
                stdio: 'pipe'
              })
            );

            await assertMetricsEndpoint(apiUrl, true);
          });

          it('exposes a HTTP server without /metrics endpoint when env set to false', async () => {
            proc = withLogging(
              fork(exePath, ['start-provider-server'], {
                env: {
                  API_URL: apiUrl,
                  CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
                  DB_CACHE_TTL: dbCacheTtl,
                  ENABLE_METRICS: 'false',
                  LOGGER_MIN_SEVERITY: 'error',
                  OGMIOS_URL: ogmiosConnection.address.webSocket,
                  POSTGRES_CONNECTION_STRING: postgresConnectionString,
                  SERVICE_NAMES: `${ServiceNames.Asset},${ServiceNames.ChainHistory},${ServiceNames.NetworkInfo},${ServiceNames.StakePool},${ServiceNames.TxSubmit},${ServiceNames.Utxo},${ServiceNames.Rewards}`
                },
                stdio: 'pipe'
              })
            );

            await assertMetricsEndpoint(apiUrl, false);
          });

          describe('exposes a HTTP server with /meta endpoint', () => {
            const buildInfo =
              '{"lastModified":1666954298,"lastModifiedDate":"20221028105138","rev":"65d78fc015bf7bd856c5febe0ba84d3ad18a069c","shortRev":"65d78fc","extra":{ "narHash":"sha256-PN60Ot9hQZIwh4LRgnPd8iiq9F3hFNXP7PYVpBlM9TQ=", "path":"/nix/store/i0sgvj906qpzw1bk7h8b3vij0z477ff6-source","sourceInfo":"/nix/store/i0sgvj906qpzw1bk7h8b3vij0z477ff6-source"}}';

            const metaResponse: ServerMetadata = {
              extra: JSON.parse(
                '{"narHash": "sha256-PN60Ot9hQZIwh4LRgnPd8iiq9F3hFNXP7PYVpBlM9TQ=", "path":"/nix/store/i0sgvj906qpzw1bk7h8b3vij0z477ff6-source", "sourceInfo":"/nix/store/i0sgvj906qpzw1bk7h8b3vij0z477ff6-source"}'
              ),
              lastModified: 1_666_954_298,
              lastModifiedDate: '20221028105138',
              rev: '65d78fc015bf7bd856c5febe0ba84d3ad18a069c',
              shortRev: '65d78fc',
              startupTime: 1_673_353_278_641
            };

            it('using CLI options', async () => {
              proc = withLogging(
                fork(
                  exePath,
                  [
                    ...baseArgs,
                    '--api-url',
                    apiUrl,
                    '--build-info',
                    buildInfo,
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    '--db-cache-ttl',
                    dbCacheTtl,
                    ServiceNames.Utxo
                  ],
                  { env: {}, stdio: 'pipe' }
                )
              );

              await assertMetaEndpoint(apiUrl, metaResponse);
            });

            it('using env variables', async () => {
              proc = withLogging(
                fork(exePath, ['start-provider-server'], {
                  env: {
                    API_URL: apiUrl,
                    BUILD_INFO: buildInfo,
                    CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
                    DB_CACHE_TTL: dbCacheTtl,
                    LOGGER_MIN_SEVERITY: 'error',
                    OGMIOS_URL: ogmiosConnection.address.webSocket,
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    SERVICE_NAMES: `${ServiceNames.Utxo}`
                  },
                  stdio: 'pipe'
                })
              );

              await assertMetaEndpoint(apiUrl, metaResponse);
            });

            it('defaults if build info is not provided on startup', async () => {
              const defaultServerMeta: ServerMetadata = { startupTime: 1_234_567 };

              proc = withLogging(
                fork(
                  exePath,
                  [
                    ...baseArgs,
                    '--api-url',
                    apiUrl,
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    '--db-cache-ttl',
                    dbCacheTtl,
                    ServiceNames.Utxo
                  ],
                  { env: {}, stdio: 'pipe' }
                )
              );

              await assertMetaEndpoint(apiUrl, defaultServerMeta);
            });

            it('exits with code 1 with provided invalid build info JSON format', (done) => {
              const invalidBuildInfo = '{"lastModified":}';

              callCliAndAssertExit(
                {
                  args: [
                    ...baseArgs,
                    '--api-url',
                    apiUrl,
                    '--build-info',
                    invalidBuildInfo,
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    '--db-cache-ttl',
                    dbCacheTtl,
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: 'Invalid JSON format of process.env.BUILD_INFO'
                },
                done
              );
            });

            it('exits with code 1 when the provided build info does not follow the JSON schema', (done) => {
              const buildInfoWithWrongProp = '{"lastModified1111": 1673457714494}';

              callCliAndAssertExit(
                {
                  args: [
                    ...baseArgs,
                    '--api-url',
                    apiUrl,
                    '--build-info',
                    buildInfoWithWrongProp,
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    '--db-cache-ttl',
                    dbCacheTtl,
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: 'is not allowed to have the additional property "lastModified1111"'
                },
                done
              );
            });
          });

          it('setting the service names via env variable takes preference over command line argument', async () => {
            proc = withLogging(
              fork(
                exePath,
                [
                  ...baseArgs,
                  '--api-url',
                  apiUrl,
                  '--postgres-connection-string',
                  postgresConnectionString,
                  '--ogmios-url',
                  ogmiosConnection.address.webSocket,
                  '--cardano-node-config-path',
                  cardanoNodeConfigPath,
                  '--db-cache-ttl',
                  dbCacheTtl,
                  ServiceNames.Utxo
                ],
                {
                  env: {
                    SERVICE_NAMES: `${ServiceNames.Utxo},${ServiceNames.Rewards}`
                  },
                  stdio: 'pipe'
                }
              )
            );

            await assertServiceHealthy(apiUrl, ServiceNames.Utxo, lastBlock);
            await assertServiceHealthy(apiUrl, ServiceNames.Rewards, lastBlock);
          });

          it('exposes a HTTP server with /stake-pool/search endpoint that includes metrics.apy, by default', async () => {
            proc = withLogging(
              fork(
                exePath,
                [
                  ...baseArgs,
                  '--api-url',
                  apiUrl,
                  '--postgres-connection-string',
                  postgresConnectionString,
                  '--ogmios-url',
                  ogmiosConnection.address.webSocket,
                  '--cardano-node-config-path',
                  cardanoNodeConfigPath,
                  '--db-cache-ttl',
                  dbCacheTtl,
                  ServiceNames.StakePool
                ],
                { env: {}, stdio: 'pipe' }
              )
            );

            await assertStakePoolApyInResponse(apiUrl, true);
          });

          it('exposes a HTTP server with /stake-pool/search endpoint that disables metrics.apy, when configured via CLI option', async () => {
            proc = withLogging(
              fork(
                exePath,
                [
                  ...baseArgs,
                  '--api-url',
                  apiUrl,
                  '--disable-stake-pool-metric-apy',
                  'true',
                  '--postgres-connection-string',
                  postgresConnectionString,
                  '--ogmios-url',
                  ogmiosConnection.address.webSocket,
                  '--cardano-node-config-path',
                  cardanoNodeConfigPath,
                  '--db-cache-ttl',
                  dbCacheTtl,
                  ServiceNames.StakePool
                ],
                { env: {}, stdio: 'pipe' }
              )
            );

            await assertStakePoolApyInResponse(apiUrl, false);
          });

          it('exposes a HTTP server with /stake-pool/search endpoint that disables metrics.apy when using env', async () => {
            proc = withLogging(
              fork(exePath, ['start-provider-server'], {
                env: {
                  API_URL: apiUrl,
                  CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
                  DB_CACHE_TTL: dbCacheTtl,
                  DISABLE_STAKE_POOL_METRIC_APY: 'true',
                  LOGGER_MIN_SEVERITY: 'error',
                  OGMIOS_URL: ogmiosConnection.address.webSocket,
                  POSTGRES_CONNECTION_STRING: postgresConnectionString,
                  SERVICE_NAMES: `${ServiceNames.StakePool}`
                },
                stdio: 'pipe'
              })
            );

            await assertStakePoolApyInResponse(apiUrl, false);
          });
        });

        describe('specifying a PostgreSQL-dependent service', () => {
          describe('without provided static nor service discovery config', () => {
            it('stake-pool exits with code 1', (done) => {
              callCliAndAssertExit(
                {
                  args: ['--service-names', ServiceNames.StakePool]
                },
                done
              );
            });

            it('network-info exits with code 1', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    '--service-names',
                    ServiceNames.NetworkInfo
                  ]
                },
                done
              );
            });

            it('network-info exits with code 1 when cache TTL is out of range', (done) => {
              const cacheTtlOutOfRange = '3000';
              callCliAndAssertExit(
                {
                  args: [
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    '--db-cache-ttl',
                    cacheTtlOutOfRange,
                    '--service-names',
                    ServiceNames.NetworkInfo
                  ]
                },
                done
              );
            });

            it('utxo exits with code 1', (done) => {
              callCliAndAssertExit(
                {
                  args: ['--service-names', ServiceNames.Utxo]
                },
                done
              );
            });

            it('rewards exits with code 1', (done) => {
              callCliAndAssertExit(
                {
                  args: ['--service-names', ServiceNames.Rewards]
                },
                done
              );
            });

            it('chain-history exits with code 1', (done) => {
              callCliAndAssertExit(
                {
                  args: ['--service-names', ServiceNames.ChainHistory]
                },
                done
              );
            });

            it('asset exits with code 1', (done) => {
              callCliAndAssertExit(
                {
                  args: ['--service-names', ServiceNames.Asset]
                },
                done
              );
            });
          });

          describe('with provided static config', () => {
            beforeEach(async () => {
              ogmiosServer = createHealthyMockOgmiosServer();
              await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
              await ogmiosServerReady(ogmiosConnection);
            });

            it('exposes a HTTP server when using CLI options', async () => {
              proc = withLogging(
                fork(
                  exePath,
                  [
                    ...baseArgs,
                    '--api-url',
                    apiUrl,
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--postgres-db',
                    postgresDb,
                    '--postgres-user',
                    postgresUser,
                    '--postgres-password',
                    postgresPassword,
                    '--postgres-host',
                    postgresHost,
                    '--postgres-pool-max',
                    '50',
                    '--postgres-port',
                    postgresPort,
                    ServiceNames.Utxo
                  ],
                  {
                    env: {},
                    stdio: 'pipe'
                  }
                )
              );

              await assertServiceHealthy(apiUrl, ServiceNames.Utxo, lastBlock);
            });

            it('exposes a HTTP server when using env variables', async () => {
              proc = withLogging(
                fork(exePath, ['start-provider-server'], {
                  env: {
                    API_URL: apiUrl,
                    LOGGER_MIN_SEVERITY: 'error',
                    OGMIOS_URL: ogmiosConnection.address.webSocket,
                    POSTGRES_DB: postgresDb,
                    POSTGRES_HOST: postgresHost,
                    POSTGRES_PASSWORD: postgresPassword,
                    POSTGRES_POOL_MAX: '50',
                    POSTGRES_PORT: postgresPort,
                    POSTGRES_USER: postgresUser,
                    SERVICE_NAMES: ServiceNames.Utxo
                  },
                  stdio: 'pipe'
                })
              );

              await assertServiceHealthy(apiUrl, ServiceNames.Utxo, lastBlock);
            });
          });

          describe('with provided service discovery config', () => {
            it('exits with code 1 if DNS server not reachable when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-srv-service-name',
                    postgresSrvServiceName,
                    '--postgres-db',
                    postgresDb,
                    '--postgres-user',
                    postgresUser,
                    '--postgres-password',
                    postgresPassword,
                    '--service-discovery-timeout',
                    '1000',
                    '--service-names',
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: DNS_SERVER_NOT_REACHABLE_ERROR
                },
                done
              );
            });

            it('exits with code 1 if DNS server not reachable when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: DNS_SERVER_NOT_REACHABLE_ERROR,
                  env: {
                    POSTGRES_DB: postgresDb,
                    POSTGRES_PASSWORD: postgresPassword,
                    POSTGRES_SRV_SERVICE_NAME: postgresSrvServiceName,
                    POSTGRES_USER: postgresUser,
                    SERVICE_DISCOVERY_TIMEOUT: '1000',
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both postgres srv service name and connection string', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--postgres-srv-service-name',
                    postgresSrvServiceName,
                    '--service-names',
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_SRV_SERVICE_NAME: postgresSrvServiceName,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both postgres srv service name and host', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-host',
                    postgresHost,
                    '--postgres-srv-service-name',
                    postgresSrvServiceName,
                    '--service-names',
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_HOST: postgresHost,
                    POSTGRES_SRV_SERVICE_NAME: postgresSrvServiceName,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both postgres srv service name and port', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-port',
                    postgresPort,
                    '--postgres-srv-service-name',
                    postgresSrvServiceName,
                    '--service-names',
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_PORT: postgresPort,
                    POSTGRES_SRV_SERVICE_NAME: postgresSrvServiceName,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both connection string and postgres db name', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--postgres-db',
                    postgresDb,
                    '--service-names',
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_DB: postgresDb,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both connection string and postgres db name file', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--postgres-db-file',
                    postgresDbFile,
                    '--service-names',
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_DB_FILE: postgresDbFile,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both connection string and postgres user', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--postgres-user',
                    postgresUser,
                    '--service-names',
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_USER: postgresUser,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both connection string and postgres user file', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--postgres-user-file',
                    postgresUserFile,
                    '--service-names',
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_USER_FILE: postgresUserFile,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both connection string and postgres password', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--postgres-password',
                    postgresPassword,
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_PASSWORD: postgresPassword,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both connection string and postgres password file', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--postgres-password-file',
                    postgresPasswordFile,
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_PASSWORD_FILE: postgresPasswordFile,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both connection string and postgres host', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--postgres-host',
                    postgresHost,
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_HOST: postgresHost,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both connection string and postgres port', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--postgres-port',
                    postgresPort,
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_PORT: postgresPort,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both postgres db name from config and from file', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: ['--postgres-db', postgresDb, '--postgres-db-file', postgresDbFile, ServiceNames.Utxo],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_DB: postgresDb,
                    POSTGRES_DB_FILE: postgresDbFile,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both postgres user from config and from file', () => {
            it('throws a CLI validation error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: ['--postgres-user', postgresUser, '--postgres-user-file', postgresUserFile, ServiceNames.Utxo],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_USER: postgresUser,
                    POSTGRES_USER_FILE: postgresUserFile,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });

          describe('with both postgres password from config and from file', () => {
            it('throws a CLI validation error and exits with code 1 whens use CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-password',
                    postgresPassword,
                    '--postgres-password-file',
                    postgresPasswordFile,
                    ServiceNames.Utxo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    POSTGRES_PASSWORD: postgresPassword,
                    POSTGRES_PASSWORD_FILE: postgresPasswordFile,
                    SERVICE_NAMES: ServiceNames.Utxo
                  }
                },
                done
              );
            });
          });
        });

        describe('specifying a Cardano-Configurations-dependent service without providing the node config path', () => {
          it('network-info exits with code 1 when using CLI options', (done) => {
            callCliAndAssertExit(
              {
                args: ['--postgres-connection-string', postgresConnectionString, ServiceNames.NetworkInfo]
              },
              done
            );
          });

          it('network-info exits with code 1 when using env variables', (done) => {
            callCliAndAssertExit(
              {
                env: {
                  POSTGRES_CONNECTION_STRING: postgresConnectionString,
                  SERVICE_NAMES: ServiceNames.NetworkInfo
                }
              },
              done
            );
          });
        });

        describe('specifying an Ogmios-dependent service', () => {
          beforeEach(async () => {
            ogmiosServer = createHealthyMockOgmiosServer();
            // ws://localhost:1337
            ogmiosConnection = Ogmios.createConnectionObject();
            await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
            await ogmiosServerReady(ogmiosConnection);
          });

          describe('without providing the Ogmios URL', () => {
            it('network-info uses the default Ogmios configuration if not specified when using CLI options', async () => {
              proc = withLogging(
                fork(
                  exePath,
                  [
                    ...baseArgs,
                    '--api-url',
                    apiUrl,
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    ServiceNames.NetworkInfo
                  ],
                  {
                    env: {},
                    stdio: 'pipe'
                  }
                )
              );
              await assertServiceHealthy(apiUrl, ServiceNames.NetworkInfo, lastBlock);
            });

            it('network-info uses the default Ogmios configuration if not specified using env variables', async () => {
              proc = withLogging(
                fork(exePath, ['start-provider-server'], {
                  env: {
                    API_URL: apiUrl,
                    CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
                    LOGGER_MIN_SEVERITY: 'error',
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    SERVICE_NAMES: ServiceNames.NetworkInfo
                  },
                  stdio: 'pipe'
                })
              );
              await assertServiceHealthy(apiUrl, ServiceNames.NetworkInfo, lastBlock);
            });

            it('tx-submit uses the default Ogmios configuration if not specified when using CLI options', async () => {
              proc = withLogging(
                fork(exePath, [...baseArgs, '--api-url', apiUrl, ServiceNames.TxSubmit], {
                  env: {},
                  stdio: 'pipe'
                })
              );
              await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit, lastBlock, false, false);
            });

            it('tx-submit uses the default Ogmios configuration if not specified when using env variables', async () => {
              proc = withLogging(
                fork(exePath, ['start-provider-server'], {
                  env: {
                    API_URL: apiUrl,
                    LOGGER_MIN_SEVERITY: 'error',
                    SERVICE_NAMES: ServiceNames.TxSubmit,
                    USE_QUEUE: 'false'
                  },
                  stdio: 'pipe'
                })
              );
              await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit, lastBlock, false, false);
            });
          });

          describe('with service discovery', () => {
            it('network-info throws DNS SRV error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    '--postgres-srv-service-name',
                    postgresSrvServiceName,
                    '--postgres-db',
                    postgresDb,
                    '--postgres-user',
                    postgresUser,
                    '--postgres-password',
                    postgresPassword,
                    '--ogmios-srv-service-name',
                    ogmiosSrvServiceName,
                    '--service-discovery-timeout',
                    '1000',
                    '--service-names',
                    ServiceNames.NetworkInfo
                  ],
                  dataMatchOnError: DNS_SERVER_NOT_REACHABLE_ERROR
                },
                done
              );
            });

            it('network-info throws DNS SRV error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: DNS_SERVER_NOT_REACHABLE_ERROR,
                  env: {
                    API_URL: apiUrl,
                    CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
                    OGMIOS_SRV_SERVICE_NAME: ogmiosSrvServiceName,
                    POSTGRES_DB: postgresDb,
                    POSTGRES_PASSWORD: postgresPassword,
                    POSTGRES_SRV_SERVICE_NAME: postgresSrvServiceName,
                    POSTGRES_USER: postgresUser,
                    SERVICE_DISCOVERY_TIMEOUT: '1000',
                    SERVICE_NAMES: ServiceNames.NetworkInfo
                  }
                },
                done
              );
            });

            it('tx-submit throws DNS SRV error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--ogmios-srv-service-name',
                    ogmiosSrvServiceName,
                    '--service-discovery-timeout',
                    '1000',
                    '--service-names',
                    ServiceNames.TxSubmit
                  ],
                  dataMatchOnError: DNS_SERVER_NOT_REACHABLE_ERROR
                },
                done
              );
            });

            it('tx-submit throws DNS SRV error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: DNS_SERVER_NOT_REACHABLE_ERROR,
                  env: {
                    API_URL: apiUrl,
                    OGMIOS_SRV_SERVICE_NAME: ogmiosSrvServiceName,
                    SERVICE_DISCOVERY_TIMEOUT: '1000',
                    SERVICE_NAMES: ServiceNames.TxSubmit
                  }
                },
                done
              );
            });
          });

          describe('with providing both Ogmios URL and SRV service name', () => {
            it('network-info throws a CLI validation error and exits with code 1 whens use CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-password',
                    postgresPassword,
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--ogmios-srv-service-name',
                    ogmiosSrvServiceName,
                    '--service_names',
                    ServiceNames.NetworkInfo
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('network-info throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    API_URL: apiUrl,
                    OGMIOS_SRV_SERVICE_NAME: ogmiosSrvServiceName,
                    OGMIOS_URL: ogmiosConnection.address.webSocket,
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    SERVICE_NAMES: ServiceNames.NetworkInfo
                  }
                },
                done
              );
            });

            it('tx-submit throws a CLI validation error and exits with code 1 whens use CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--ogmios-srv-service-name',
                    ogmiosSrvServiceName,
                    '--service_names',
                    ServiceNames.TxSubmit
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('tx-submit throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    API_URL: apiUrl,
                    OGMIOS_SRV_SERVICE_NAME: ogmiosSrvServiceName,
                    OGMIOS_URL: ogmiosConnection.address.webSocket,
                    SERVICE_NAMES: ServiceNames.TxSubmit
                  }
                },
                done
              );
            });
          });

          describe('specifying ssl ca file path that does not exist', () => {
            const invalidFilePath = 'this-is-not-a-valid-file-path';

            it('exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    '--postgres-ssl-ca-file',
                    invalidFilePath,
                    '--service-names',
                    ServiceNames.NetworkInfo
                  ],
                  dataMatchOnError: 'ENOENT: no such file or directory'
                },
                done
              );
            });

            it('exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: 'ENOENT: no such file or directory',
                  env: {
                    API_URL: apiUrl,
                    CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
                    OGMIOS_URL: ogmiosConnection.address.webSocket,
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_SSL_CA_FILE: invalidFilePath,
                    SERVICE_NAMES: ServiceNames.NetworkInfo
                  }
                },
                done
              );
            });
          });

          describe('specifying ssl ca file path to an invalid cert', () => {
            it('exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--cardano-node-config-path',
                    cardanoNodeConfigPath,
                    '--postgres-ssl-ca-file',
                    postgresSslCaFile,
                    '--service-names',
                    ServiceNames.NetworkInfo
                  ],
                  dataMatchOnError: 'The server does not support SSL connections'
                },
                done
              );
            });

            it('exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: 'The server does not support SSL connections',
                  env: {
                    API_URL: apiUrl,
                    CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
                    OGMIOS_URL: ogmiosConnection.address.webSocket,
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    POSTGRES_SSL_CA_FILE: postgresSslCaFile,
                    SERVICE_NAMES: ServiceNames.NetworkInfo
                  }
                },
                done
              );
            });
          });

          describe('specifying a Token-Registry-dependent service', () => {
            let closeMock: () => Promise<void> = jest.fn();
            let tokenMetadataServerUrl = '';
            let serverUrl = ';';
            let asset: AssetData;
            let record: any;

            beforeAll(async () => {
              asset = (await fixtureBuilder.getAssets(1, { with: [AssetWith.CIP25Metadata] }))[0];
              record = {
                name: { value: asset.name },
                subject: asset.id
              };

              ({ closeMock, serverUrl } = await mockTokenRegistry(() => ({
                body: { subjects: [record] }
              })));
              tokenMetadataServerUrl = serverUrl;
            });

            afterAll(async () => await closeMock());

            it('exposes a HTTP server with healthy state when using CLI options', async () => {
              proc = withLogging(
                fork(
                  exePath,
                  [
                    ...baseArgs,
                    '--api-url',
                    apiUrl,
                    '--ogmios-url',
                    ogmiosConnection.address.webSocket,
                    '--postgres-connection-string',
                    postgresConnectionString,
                    '--token-metadata-server-url',
                    tokenMetadataServerUrl,
                    ServiceNames.Asset
                  ],
                  { env: {}, stdio: 'pipe' }
                )
              );
              await assertServiceHealthy(apiUrl, ServiceNames.Asset, lastBlock);

              const res = await axios.post(`${apiUrl}/asset/get-asset`, {
                assetId: asset.id,
                extraData: { tokenMetadata: true }
              });

              const { tokenMetadata } = fromSerializableObject<Asset.AssetInfo>(res.data);
              expect(tokenMetadata).toStrictEqual({ name: asset.name });
            });

            it('exposes a HTTP server with healthy state when using env variables', async () => {
              proc = withLogging(
                fork(exePath, ['start-provider-server'], {
                  env: {
                    API_URL: apiUrl,
                    LOGGER_MIN_SEVERITY: 'error',
                    OGMIOS_URL: ogmiosConnection.address.webSocket,
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    SERVICE_NAMES: ServiceNames.Asset,
                    TOKEN_METADATA_SERVER_URL: tokenMetadataServerUrl
                  },
                  stdio: 'pipe'
                })
              );
              await assertServiceHealthy(apiUrl, ServiceNames.Asset, lastBlock);

              const res = await axios.post(`${apiUrl}/asset/get-asset`, {
                assetId: asset.id,
                extraData: { tokenMetadata: true }
              });

              const { tokenMetadata } = fromSerializableObject<Asset.AssetInfo>(res.data);
              expect(tokenMetadata).toStrictEqual({ name: asset.name });
            });

            it('loads a stub asset metadata service when TOKEN_METADATA_SERVER_URL starts with "stub:"', async () => {
              proc = withLogging(
                fork(exePath, ['start-provider-server'], {
                  env: {
                    API_URL: apiUrl,
                    LOGGER_MIN_SEVERITY: 'error',
                    OGMIOS_URL: ogmiosConnection.address.webSocket,
                    POSTGRES_CONNECTION_STRING: postgresConnectionString,
                    SERVICE_NAMES: ServiceNames.Asset,
                    TOKEN_METADATA_SERVER_URL: 'stub://'
                  },
                  stdio: 'pipe'
                })
              );
              await assertServiceHealthy(apiUrl, ServiceNames.Asset, lastBlock);

              const res = await axios.post(`${apiUrl}/asset/get-asset`, {
                assetId: asset.id,
                extraData: { tokenMetadata: true }
              });

              const { tokenMetadata } = fromSerializableObject<Asset.AssetInfo>(res.data);
              expect(tokenMetadata).toBeNull();
            });
          });
        });

        describe('specifying a RabbitMQ-dependent service', () => {
          describe('with RabbitMQ and explicit URL', () => {
            it('exposes a HTTP server with healthy state when using CLI options', async () => {
              proc = withLogging(
                fork(
                  exePath,
                  [
                    ...baseArgs,
                    '--api-url',
                    apiUrl,
                    '--use-queue',
                    'true',
                    '--rabbitmq-url',
                    rabbitmqUrl.toString(),
                    ServiceNames.TxSubmit
                  ],
                  {
                    env: {},
                    stdio: 'pipe'
                  }
                )
              );
              await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit, lastBlock, true, true);
            });

            it('exposes a HTTP server with healthy state when using env variables', async () => {
              proc = withLogging(
                fork(exePath, ['start-provider-server'], {
                  env: {
                    API_URL: apiUrl,
                    LOGGER_MIN_SEVERITY: 'error',
                    RABBITMQ_URL: rabbitmqUrl.toString(),
                    SERVICE_NAMES: ServiceNames.TxSubmit,
                    USE_QUEUE: 'true'
                  },
                  stdio: 'pipe'
                })
              );
              await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit, lastBlock, true, true);
            });
          });

          describe('with service discovery', () => {
            it('tx-submit throws DNS SRV error and exits with code 1 when using CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--use-queue',
                    'true',
                    '--rabbitmq-srv-service-name',
                    rabbitmqSrvServiceName,
                    '--service-discovery-timeout',
                    '1000',
                    '--service-names',
                    ServiceNames.TxSubmit
                  ],
                  dataMatchOnError: DNS_SERVER_NOT_REACHABLE_ERROR
                },
                done
              );
            });

            it('tx-submit throws DNS SRV error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: DNS_SERVER_NOT_REACHABLE_ERROR,
                  env: {
                    API_URL: apiUrl,
                    RABBITMQ_SRV_SERVICE_NAME: rabbitmqSrvServiceName,
                    SERVICE_DISCOVERY_TIMEOUT: '1000',
                    SERVICE_NAMES: ServiceNames.TxSubmit,
                    USE_QUEUE: 'true'
                  }
                },
                done
              );
            });
          });

          describe('with providing both RabbitMQ URL and SRV service name', () => {
            it('tx-submit throws a CLI validation error and exits with code 1 whens use CLI options', (done) => {
              callCliAndAssertExit(
                {
                  args: [
                    '--use-queue',
                    'true',
                    '--rabbitmq-srv-service-name',
                    rabbitmqSrvServiceName,
                    '--rabbitmq-url',
                    rabbitmqUrl.toString(),
                    '--service-discovery-timeout',
                    '1000',
                    '--service_names',
                    ServiceNames.TxSubmit
                  ],
                  dataMatchOnError: CLI_CONFLICTING_OPTIONS_ERROR_MESSAGE
                },
                done
              );
            });

            it('tx-submit throws a CLI validation error and exits with code 1 when using env variables', (done) => {
              callCliAndAssertExit(
                {
                  dataMatchOnError: CLI_CONFLICTING_ENV_VARS_ERROR_MESSAGE,
                  env: {
                    API_URL: apiUrl,
                    RABBITMQ_SRV_SERVICE_NAME: rabbitmqSrvServiceName,
                    RABBITMQ_URL: rabbitmqUrl.toString(),
                    SERVICE_DISCOVERY_TIMEOUT: '1000',
                    SERVICE_NAMES: ServiceNames.TxSubmit,
                    USE_QUEUE: 'true'
                  }
                },
                done
              );
            });
          });
        });
      });

      describe('with unhealthy internal providers', () => {
        beforeEach(() => {
          ogmiosServer = createUnhealthyMockOgmiosServer();
        });

        it('exits with code 1', (done) => {
          ogmiosServer.listen(ogmiosConnection.port, () => {
            callCliAndAssertExit(
              {
                args: [
                  '--postgres-connection-string',
                  postgresConnectionString,
                  '--ogmios-url',
                  ogmiosConnection.address.webSocket,
                  '--service_names',
                  ServiceNames.StakePool,
                  ServiceNames.TxSubmit
                ]
              },
              done
            );
          });
        });
      });

      describe('specifying an unknown service', () => {
        beforeEach(() => {
          ogmiosServer = createHealthyMockOgmiosServer();
        });

        it('cli:start-provider-server exits with code 1', (done) => {
          ogmiosServer.listen(ogmiosConnection.port, () => {
            callCliAndAssertExit(
              {
                args: [
                  '--ogmios-url',
                  ogmiosConnection.address.webSocket,
                  'some-unknown-service',
                  ServiceNames.TxSubmit
                ]
              },
              done
            );
          });
        });
      });
    });
  });

  describe('start-blockfrost-worker', () => {
    const commonArgs = ['start-blockfrost-worker', '--logger-min-severity', 'info', '--dry-run', 'true'];
    let port: number;
    let proc: ChildProcess;

    beforeAll(async () => {
      port = await getRandomPort();
    });

    afterEach((done) => {
      if (proc?.kill()) proc.on('close', () => done());
      else done();
    });

    // Tests without any assertion fail if they get timeout
    it('exits with code 1 without api key', (done) => {
      expect.assertions(2);
      proc = withLogging(fork(exePath, commonArgs, { env: {}, stdio: 'pipe' }), true);
      proc.stderr!.on('data', (data) =>
        expect(data.toString()).toMatch(
          'MissingProgramOption: Blockfrost worker requires the Blockfrost API Key file path or Blockfrost API Key program option'
        )
      );
      proc.on('exit', (code) => {
        expect(code).toBe(1);
        done();
      });
    });

    it('exits with code 1 without network', (done) => {
      expect.assertions(2);
      proc = withLogging(
        fork(exePath, [...commonArgs, '--blockfrost-api-key', 'abc'], { env: {}, stdio: 'pipe' }),
        true
      );
      proc.stderr!.on('data', (data) =>
        expect(data.toString()).toMatch(
          'MissingProgramOption: Blockfrost worker requires the network to run against program option'
        )
      );
      proc.on('exit', (code) => {
        expect(code).toBe(1);
        done();
      });
    });

    it('exits with code 1 with wrong network', (done) => {
      expect.assertions(2);
      proc = withLogging(
        fork(exePath, [...commonArgs, '--blockfrost-api-key', 'abc', '--network', 'none'], {
          env: {},
          stdio: 'pipe'
        }),
        true
      );
      proc.stderr!.on('data', (data) => expect(data.toString()).toMatch('Error: Unknown network: none'));
      proc.on('exit', (code) => {
        expect(code).toBe(1);
        done();
      });
    });

    it('exits with code 1 without db connection string', (done) => {
      expect.assertions(2);
      proc = withLogging(
        fork(exePath, [...commonArgs, '--blockfrost-api-key', 'abc', '--network', 'mainnet'], {
          env: {},
          stdio: 'pipe'
        }),
        true
      );
      proc.stderr!.on('data', (data) =>
        expect(data.toString()).toMatch(
          'MissingProgramOption: Blockfrost worker requires the PostgreSQL Connection string or Postgres SRV service name, db, user and password program option'
        )
      );
      proc.on('exit', (code) => {
        expect(code).toBe(1);
        done();
      });
    });

    it('dry run', (done) => {
      proc = withLogging(
        fork(
          exePath,
          [
            ...commonArgs,
            '--blockfrost-api-key',
            'abc',
            '--network',
            'mainnet',
            '--postgres-connection-string',
            process.env.POSTGRES_CONNECTION_STRING!,
            '--api-url',
            `http://localhost:${port}/`
          ],
          { env: {}, stdio: 'pipe' }
        )
      );
      proc.stdout!.on('data', (data) => {
        // eslint-disable-next-line unicorn/prefer-regexp-test
        if (data.toString('utf8').match(/Sleeping for \d+ milliseconds to start next run/)) done();
      });
    });
  });

  describe('start-worker', () => {
    let commonArgs: string[];
    let commonArgsWithServiceDiscovery: string[];
    let commonEnv: Record<string, string>;
    let commonEnvWithServiceDiscovery: Record<string, string>;
    let hook: () => void;
    let hookPromise: Promise<void>;
    let ogmiosServer: http.Server;
    let proc: ChildProcess;
    let rabbitmqUrl: URL;
    let rabbitmqSrvServiceName: string;
    let ogmiosSrvServiceName: string;

    const resetHook = () => (hook = jest.fn());

    beforeAll(async () => {
      ({ rabbitmqUrl } = await container.load());
      resetHook();
      const port = await getRandomPort();
      const ogmiosConnection = Ogmios.createConnectionObject({ port });
      ogmiosServer = createHealthyMockOgmiosServer(() => hook());
      rabbitmqSrvServiceName = process.env.RABBITMQ_SRV_SERVICE_NAME!;
      ogmiosSrvServiceName = process.env.OGMIOS_SRV_SERVICE_NAME!;
      await listenPromise(ogmiosServer, { port });
      await ogmiosServerReady(ogmiosConnection);
      commonArgs = [
        'start-worker',
        '--logger-min-severity',
        'error',
        '--ogmios-url',
        ogmiosConnection.address.webSocket,
        '--rabbitmq-url',
        rabbitmqUrl.toString()
      ];
      commonArgsWithServiceDiscovery = [
        'start-worker',
        '--logger-min-severity',
        'error',
        '--rabbitmq-srv-service-name',
        rabbitmqSrvServiceName,
        '--ogmios-srv-service-name',
        ogmiosSrvServiceName,
        '--service-discovery-timeout',
        '1000'
      ];
      commonEnv = {
        LOGGER_MIN_SEVERITY: 'error',
        OGMIOS_URL: ogmiosConnection.address.webSocket,
        RABBITMQ_URL: rabbitmqUrl.toString()
      };
      commonEnvWithServiceDiscovery = {
        LOGGER_MIN_SEVERITY: 'error',
        OGMIOS_SRV_SERVICE_NAME: ogmiosSrvServiceName,
        RABBITMQ_SRV_SERVICE_NAME: rabbitmqSrvServiceName,
        SERVICE_DISCOVERY_TIMEOUT: '1000'
      };
    });

    afterAll(async () => await serverClosePromise(ogmiosServer));

    beforeEach(async () => {
      await container.removeQueues();
    });

    afterEach((done) => {
      resetHook();
      if (proc?.kill()) proc.on('close', () => done());
      else done();
    });

    // Tests without any assertion fail if they get timeout
    describe('cli:start-worker with a working RabbitMQ server', () => {
      describe('transaction are actually submitted', () => {
        it('submits transactions using CLI options', async () => {
          hookPromise = new Promise((resolve) => (hook = resolve));
          proc = withLogging(fork(exePath, commonArgs, { env: {}, stdio: 'pipe' }));
          await Promise.all([hookPromise, container.enqueueTx(logger)]);
        });

        it('submits transactions using env variables', async () => {
          hookPromise = new Promise((resolve) => (hook = resolve));
          proc = withLogging(fork(exePath, ['start-worker'], { env: commonEnv, stdio: 'pipe' }));
          await Promise.all([hookPromise, container.enqueueTx(logger)]);
        });
      });

      describe('parallel option', () => {
        describe('without parallel option', () => {
          it('starts in serial mode', (done) => {
            proc = withLogging(fork(exePath, commonArgs, { env: {}, stdio: 'pipe' }));
            proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
          });

          it('starts in serial mode', (done) => {
            proc = withLogging(fork(exePath, ['start-worker'], { env: commonEnv, stdio: 'pipe' }));
            proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
          });
        });

        describe('with bad parallel option', () => {
          it('exits with code 1 using CLI options', (done) => {
            expect.assertions(2);
            proc = withLogging(fork(exePath, [...commonArgs, '--parallel', 'test'], { env: {}, stdio: 'pipe' }), true);
            proc.stderr!.on('data', (data) =>
              expect(data.toString()).toMatch('RabbitMQ worker requires a valid Parallel mode')
            );
            proc.on('exit', (code) => {
              expect(code).toBe(1);
              done();
            });
          });

          it('exits with code 1 using env variables', (done) => {
            expect.assertions(2);
            proc = withLogging(
              fork(exePath, ['start-worker'], { env: { ...commonEnv, PARALLEL: 'test' }, stdio: 'pipe' }),
              true
            );
            proc.stderr!.on('data', (data) =>
              expect(data.toString()).toMatch('RabbitMQ worker requires a valid Parallel mode')
            );
            proc.on('exit', (code) => {
              expect(code).toBe(1);
              done();
            });
          });
        });

        describe('with parallel option set to false', () => {
          it('worker starts in serial mode using CLI options', (done) => {
            proc = withLogging(fork(exePath, [...commonArgs, '--parallel', 'false'], { env: {}, stdio: 'pipe' }));
            proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
          });

          it('worker starts in serial mode using env variables', (done) => {
            proc = withLogging(
              fork(exePath, ['start-worker'], { env: { ...commonEnv, PARALLEL: 'false' }, stdio: 'pipe' })
            );
            proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
          });
        });

        describe('with parallel option set to true', () => {
          it('worker starts in parallel mode using CLI options', (done) => {
            proc = withLogging(fork(exePath, [...commonArgs, '--parallel', 'true'], { env: {}, stdio: 'pipe' }));
            proc.stdout!.on('data', (data) => (data.toString().match('parallel mode') ? done() : null));
          });

          it('worker starts in parallel mode using env variables', (done) => {
            proc = withLogging(
              fork(exePath, ['start-worker'], { env: { ...commonEnv, PARALLEL: 'true' }, stdio: 'pipe' })
            );
            proc.stdout!.on('data', (data) => (data.toString().match('parallel mode') ? done() : null));
          });
        });

        describe('default parallel option value', () => {
          it('worker starts in parallel mode using CLI options', (done) => {
            proc = withLogging(fork(exePath, [...commonArgs, '--parallel', 'true'], { env: {}, stdio: 'pipe' }));
            proc.stdout!.on('data', (data) => (data.toString().match('parallel mode') ? done() : null));
          });
        });
      });
    });

    describe('without a working RabbitMQ server handles a connection error event', () => {
      it('exits with code 1 using CLI options', (done) => {
        expect.assertions(2);
        proc = withLogging(
          fork(exePath, [...commonArgs, '--rabbitmq-url', BAD_CONNECTION_URL.toString()], {
            env: {},
            stdio: 'pipe'
          }),
          true
        );

        proc.stderr!.on('data', (data) => {
          expect(data.toString()).toMatch('CONNECTION_FAILURE');
        });
        proc.on('exit', (code) => {
          expect(code).toBe(1);
          done();
        });
      });

      it('exits with code 1 using env variables', (done) => {
        expect.assertions(2);
        proc = withLogging(
          fork(exePath, ['start-worker'], {
            env: { ...commonEnv, RABBITMQ_URL: BAD_CONNECTION_URL.toString() },
            stdio: 'pipe'
          }),
          true
        );

        proc.stderr!.on('data', (data) => {
          expect(data.toString()).toMatch('CONNECTION_FAILURE');
        });
        proc.on('exit', (code) => {
          expect(code).toBe(1);
          done();
        });
      });
    });

    describe('with service discovery', () => {
      it('throws DNS SRV error and exits with code 1 using CLI options', (done) => {
        expect.assertions(2);
        proc = withLogging(fork(exePath, commonArgsWithServiceDiscovery, { env: {}, stdio: 'pipe' }), true);

        proc.stderr!.on('data', (data) => {
          expect(data.toString().includes('querySrv ENOTFOUND')).toEqual(true);
        });

        proc.on('exit', (code) => {
          expect(code).toBe(1);
          done();
        });
      });

      it('throws DNS SRV error and exits with code 1 using env variables', (done) => {
        expect.assertions(2);
        proc = withLogging(
          fork(exePath, ['start-worker'], { env: commonEnvWithServiceDiscovery, stdio: 'pipe' }),
          true
        );

        proc.stderr!.on('data', (data) => {
          expect(data.toString().includes('querySrv ENOTFOUND')).toEqual(true);
        });

        proc.on('exit', (code) => {
          expect(code).toBe(1);
          done();
        });
      });
    });
  });
});
