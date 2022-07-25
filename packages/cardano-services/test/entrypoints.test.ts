/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable max-len */
import { ChildProcess, fork } from 'child_process';
import { Ogmios } from '@cardano-sdk/ogmios';
import { RABBITMQ_URL_DEFAULT, ServiceNames } from '../src';
import { createHealthyMockOgmiosServer, createUnhealthyMockOgmiosServer, ogmiosServerReady, serverReady } from './util';
import { fromSerializableObject } from '@cardano-sdk/util';
import { getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../src/util';
import { mockTokenRegistry } from './Asset/CardanoTokenRegistry.test';
import axios from 'axios';
import http from 'http';
import path from 'path';

const exePath = (name: 'cli' | 'run') => path.join(__dirname, '..', 'dist', 'cjs', `${name}.js`);

const assertServiceHealthy = async (apiUrl: string, serviceName: ServiceNames) => {
  await serverReady(apiUrl);
  const headers = { 'Content-Type': 'application/json' };
  const res = await axios.post(`${apiUrl}/${serviceName}/health`, { headers });
  expect(res.status).toBe(200);
  expect(res.data).toEqual({ ok: true });
};

describe('entrypoints', () => {
  let apiPort: number;
  let apiUrl: string;
  let ogmiosServer: http.Server;
  let proc: ChildProcess;

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
    proc = fork(exePath('cli'), ['--version'], {
      stdio: 'pipe'
    });
    proc.stdout!.on('data', (data) => {
      expect(data.toString()).toBeDefined();
    });
    proc.stdout?.on('end', () => {
      done();
    });
  });

  describe('start-server', () => {
    let postgresConnectionString: string;
    let ogmiosPort: Ogmios.ConnectionConfig['port'];
    let ogmiosConnection: Ogmios.Connection;
    let cardanoNodeConfigPath: string;
    let dbCacheTtl: string;
    let postgresSrvServiceName: string;
    let postgresDb: string;
    let postgresUser: string;
    let postgresPassword: string;
    let ogmiosSrvServiceName: string;
    let rabbitmqSrvServiceName: string;

    beforeAll(async () => {
      ogmiosPort = await getRandomPort();
      ogmiosConnection = Ogmios.createConnectionObject({ port: ogmiosPort });
      postgresConnectionString = process.env.POSTGRES_CONNECTION_STRING!;
      cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
      postgresSrvServiceName = process.env.POSTGRES_SRV_SERVICE_NAME!;
      postgresDb = process.env.POSTGRES_DB!;
      postgresUser = process.env.POSTGRES_USER!;
      postgresPassword = process.env.POSTGRES_PASSWORD!;
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

        it('cli:start-server exposes a HTTP server at the configured URL with all services attached', async () => {
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              apiUrl,
              '--postgres-connection-string',
              postgresConnectionString,
              '--logger-min-severity',
              'error',
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
              ServiceNames.Utxo
            ],
            { stdio: 'pipe' }
          );
          await assertServiceHealthy(apiUrl, ServiceNames.Asset);
          await assertServiceHealthy(apiUrl, ServiceNames.ChainHistory);
          await assertServiceHealthy(apiUrl, ServiceNames.NetworkInfo);
          await assertServiceHealthy(apiUrl, ServiceNames.StakePool);
          await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
          await assertServiceHealthy(apiUrl, ServiceNames.Utxo);
        });

        it('run exposes a HTTP server at the configured URL with all services attached', async () => {
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
              DB_CACHE_TTL: dbCacheTtl,
              LOGGER_MIN_SEVERITY: 'error',
              OGMIOS_URL: ogmiosConnection.address.webSocket,
              POSTGRES_CONNECTION_STRING: postgresConnectionString,
              SERVICE_NAMES: `${ServiceNames.Asset},${ServiceNames.ChainHistory},${ServiceNames.NetworkInfo},${ServiceNames.StakePool},${ServiceNames.TxSubmit},${ServiceNames.Utxo}`
            },
            stdio: 'pipe'
          });
          await assertServiceHealthy(apiUrl, ServiceNames.Asset);
          await assertServiceHealthy(apiUrl, ServiceNames.ChainHistory);
          await assertServiceHealthy(apiUrl, ServiceNames.NetworkInfo);
          await assertServiceHealthy(apiUrl, ServiceNames.StakePool);
          await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
          await assertServiceHealthy(apiUrl, ServiceNames.Utxo);
        });
      });

      describe('specifying a PostgreSQL-dependent service without providing the connection string', () => {
        let spy: jest.Mock;
        beforeEach(() => {
          spy = jest.fn();
        });

        it('cli:start-server stake-pool exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(
            exePath('cli'),
            ['start-server', '--api-url', apiUrl, '--logger-min-severity', 'error', ServiceNames.StakePool],
            {
              stdio: 'pipe'
            }
          );
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });

        it('cli:start-server network-info exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              apiUrl,
              '--logger-min-severity',
              'error',
              '--cardano-node-config-path',
              cardanoNodeConfigPath,
              ServiceNames.NetworkInfo
            ],
            {
              stdio: 'pipe'
            }
          );
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });

        it('cli:start-server network-info exits with code 1 when cache TTL is out of range', (done) => {
          expect.assertions(2);
          const cacheTtlOutOfRange = '3000';
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              apiUrl,
              '--logger-min-severity',
              'error',
              '--cardano-node-config-path',
              cardanoNodeConfigPath,
              '--db-cache-ttl',
              cacheTtlOutOfRange,
              ServiceNames.NetworkInfo
            ],
            {
              stdio: 'pipe'
            }
          );
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });

        it('cli:start-server utxo exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              apiUrl,
              '--logger-min-severity',
              'error',
              '--cardano-node-config-path',
              cardanoNodeConfigPath,
              ServiceNames.Utxo
            ],
            {
              stdio: 'pipe'
            }
          );
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });

        it('run stake-pool exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              LOGGER_MIN_SEVERITY: 'error',
              SERVICE_NAMES: ServiceNames.StakePool
            },
            stdio: 'pipe'
          });
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });

        it('run network-info exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              LOGGER_MIN_SEVERITY: 'error',
              SERVICE_NAMES: ServiceNames.NetworkInfo
            },
            stdio: 'pipe'
          });
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });

        it('run network-info exits with code 1 when cache TTL is out of range', (done) => {
          expect.assertions(2);
          const cacheTtlOutOfRange = '3000';
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              DB_CACHE_TTL: cacheTtlOutOfRange,
              LOGGER_MIN_SEVERITY: 'error',
              SERVICE_NAMES: ServiceNames.NetworkInfo
            },
            stdio: 'pipe'
          });
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });

        it('run utxo exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              LOGGER_MIN_SEVERITY: 'error',
              SERVICE_NAMES: ServiceNames.Utxo
            },
            stdio: 'pipe'
          });
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });
      });

      describe('specifying PostgreSQL-dependent services with service discovery args', () => {
        let spy: jest.Mock;
        beforeEach(async () => {
          spy = jest.fn();
        });

        it('cli:start-server throws DNS SRV error and exits with code 1', (done) => {
          expect.assertions(3);
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              apiUrl,
              '--postgres-srv-service-name',
              postgresSrvServiceName,
              '--postgres-db',
              postgresDb,
              '--postgres-user',
              postgresUser,
              '--postgres-password',
              postgresPassword,
              '--logger-min-severity',
              'error',
              '--service-discovery-timeout',
              '1000',
              ServiceNames.StakePool,
              ServiceNames.NetworkInfo,
              ServiceNames.Utxo
            ],
            {
              stdio: 'pipe'
            }
          );

          proc.stderr!.on('data', (data) => {
            spy();
            expect(data.toString().includes('querySrv ENOTFOUND')).toEqual(true);
          });

          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });

        it('run throws DNS SRV error and exits with code 1', (done) => {
          expect.assertions(3);
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              LOGGER_MIN_SEVERITY: 'error',
              POSTGRES_DB: postgresDb,
              POSTGRES_PASSWORD: postgresPassword,
              POSTGRES_SRV_SERVICE_NAME: postgresSrvServiceName,
              POSTGRES_USER: postgresUser,
              SERVICE_DISCOVERY_TIMEOUT: '1000',
              SERVICE_NAMES: `${ServiceNames.StakePool},${ServiceNames.NetworkInfo},${ServiceNames.Utxo}`
            },
            stdio: 'pipe'
          });
          proc.stderr!.on('data', (data) => {
            spy();
            expect(data.toString().includes('querySrv ENOTFOUND')).toEqual(true);
          });
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });
      });

      describe('specifying a Cardano-Configurations-dependent service without providing the node config path', () => {
        let spy: jest.Mock;
        beforeEach(() => {
          spy = jest.fn();
        });

        it('cli:start-server network-info exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              apiUrl,
              '--postgres-connection-string',
              postgresConnectionString,
              '--logger-min-severity',
              'error',
              ServiceNames.NetworkInfo
            ],
            {
              stdio: 'pipe'
            }
          );
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });

        it('run network-info exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              LOGGER_MIN_SEVERITY: 'error',
              POSTGRES_CONNECTION_STRING: postgresConnectionString,
              SERVICE_NAMES: ServiceNames.NetworkInfo
            },
            stdio: 'pipe'
          });
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });
      });

      describe('specifying an Ogmios-dependent service without providing the Ogmios URL', () => {
        beforeEach(async () => {
          ogmiosServer = createHealthyMockOgmiosServer();
          // ws://localhost:1337
          ogmiosConnection = Ogmios.createConnectionObject();
          await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
          await ogmiosServerReady(ogmiosConnection);
        });

        it('cli:start-server uses the default Ogmios configuration if not specified', async () => {
          proc = fork(
            exePath('cli'),
            ['start-server', '--api-url', apiUrl, '--logger-min-severity', 'error', ServiceNames.TxSubmit],
            {
              stdio: 'pipe'
            }
          );
          await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
        });

        it('run uses the default Ogmios configuration if not specified', async () => {
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              LOGGER_MIN_SEVERITY: 'error',
              SERVICE_NAMES: ServiceNames.TxSubmit
            },
            stdio: 'pipe'
          });
          await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
        });
      });

      describe('using the asset service', () => {
        let closeMock: () => Promise<void> = jest.fn();
        let tokenMetadataServerUrl = '';
        const record = {
          name: { value: 'test' },
          subject: '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65'
        };

        beforeAll(async () => {
          ({ closeMock, tokenMetadataServerUrl } = await mockTokenRegistry(() => ({ body: { subjects: [record] } })));
        });

        afterAll(async () => await closeMock());

        it('cli:start-server uses the asset service', async () => {
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              apiUrl,
              '--postgres-connection-string',
              postgresConnectionString,
              '--logger-min-severity',
              'error',
              '--token-metadata-server-url',
              tokenMetadataServerUrl,
              ServiceNames.Asset
            ],
            { stdio: 'pipe' }
          );

          await assertServiceHealthy(apiUrl, ServiceNames.Asset);

          const res = await axios.post(`${apiUrl}/asset/get-asset`, {
            args: [
              '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65',
              { tokenMetadata: true }
            ]
          });

          const { tokenMetadata } = fromSerializableObject(res.data);
          expect(tokenMetadata).toStrictEqual({ name: 'test' });
        });

        it('run uses the asset service', async () => {
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              LOGGER_MIN_SEVERITY: 'error',
              POSTGRES_CONNECTION_STRING: postgresConnectionString,
              SERVICE_NAMES: ServiceNames.Asset,
              TOKEN_METADATA_SERVER_URL: tokenMetadataServerUrl
            },
            stdio: 'pipe'
          });

          await assertServiceHealthy(apiUrl, ServiceNames.Asset);

          const res = await axios.post(`${apiUrl}/asset/get-asset`, {
            args: [
              '50fdcdbfa3154db86a87e4b5697ae30d272e0bbcfa8122efd3e301cb6d616361726f6e2d63616b65',
              { tokenMetadata: true }
            ]
          });

          const { tokenMetadata } = fromSerializableObject(res.data);
          expect(tokenMetadata).toStrictEqual({ name: 'test' });
        });
      });
    });

    describe('specifying an Ogmios-dependent service with service discovery args', () => {
      let spy: jest.Mock;
      beforeEach(async () => {
        spy = jest.fn();
      });

      it('cli:start-server throws DNS SRV error and exits with code 1', (done) => {
        expect.assertions(3);
        proc = fork(
          exePath('cli'),
          [
            'start-server',
            '--api-url',
            apiUrl,
            '--ogmios-srv-service-name',
            ogmiosSrvServiceName,
            '--logger-min-severity',
            'error',
            '--service-discovery-timeout',
            '1000',
            ServiceNames.TxSubmit
          ],
          {
            stdio: 'pipe'
          }
        );

        proc.stderr!.on('data', (data) => {
          spy();
          expect(data.toString().includes('querySrv ENOTFOUND')).toEqual(true);
        });

        proc.on('exit', (code) => {
          expect(code).toBe(1);
          expect(spy).toHaveBeenCalled();
          done();
        });
      });

      it('run throws DNS SRV error and exits with code 1', (done) => {
        expect.assertions(3);
        proc = fork(exePath('run'), {
          env: {
            API_URL: apiUrl,
            LOGGER_MIN_SEVERITY: 'error',
            OGMIOS_SRV_SERVICE_NAME: ogmiosSrvServiceName,
            SERVICE_DISCOVERY_TIMEOUT: '1000',
            SERVICE_NAMES: ServiceNames.TxSubmit
          },
          stdio: 'pipe'
        });
        proc.stderr!.on('data', (data) => {
          spy();
          expect(data.toString().includes('querySrv ENOTFOUND')).toEqual(true);
        });
        proc.on('exit', (code) => {
          expect(code).toBe(1);
          expect(spy).toHaveBeenCalled();
          done();
        });
      });
    });

    describe('with RabbitMQ and explicit URL', () => {
      it('cli:start-server', async () => {
        proc = fork(
          exePath('cli'),
          [
            'start-server',
            '--api-url',
            apiUrl,
            '--logger-min-severity',
            'error',
            '--use-queue',
            '--rabbitmq-url',
            RABBITMQ_URL_DEFAULT,
            ServiceNames.TxSubmit
          ],
          {
            stdio: 'pipe'
          }
        );
        await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
      });

      it('run', async () => {
        proc = fork(exePath('run'), {
          env: {
            API_URL: apiUrl,
            LOGGER_MIN_SEVERITY: 'error',
            RABBITMQ_URL: RABBITMQ_URL_DEFAULT,
            SERVICE_NAMES: ServiceNames.TxSubmit,
            USE_QUEUE: 'true'
          },
          stdio: 'pipe'
        });
        await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
      });
    });

    describe('with RabbitMQ and default URL', () => {
      it('cli:start-server', async () => {
        proc = fork(
          exePath('cli'),
          ['start-server', '--api-url', apiUrl, '--logger-min-severity', 'error', '--use-queue', ServiceNames.TxSubmit],
          {
            stdio: 'pipe'
          }
        );
        await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
      });

      it('run', async () => {
        proc = fork(exePath('run'), {
          env: {
            API_URL: apiUrl,
            LOGGER_MIN_SEVERITY: 'error',
            SERVICE_NAMES: ServiceNames.TxSubmit,
            USE_QUEUE: 'true'
          },
          stdio: 'pipe'
        });
        await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
      });
    });

    describe('specifying a RabbitMQ-dependent service with service discovery args', () => {
      let spy: jest.Mock;
      beforeEach(async () => {
        spy = jest.fn();
      });

      it('cli:start-server throws DNS SRV error and exits with code 1', (done) => {
        expect.assertions(3);
        proc = fork(
          exePath('cli'),
          [
            'start-server',
            '--api-url',
            apiUrl,
            '--use-queue',
            '--rabbitmq-srv-service-name',
            rabbitmqSrvServiceName,
            '--logger-min-severity',
            'error',
            '--service-discovery-timeout',
            '1000',
            ServiceNames.TxSubmit
          ],
          {
            stdio: 'pipe'
          }
        );

        proc.stderr!.on('data', (data) => {
          spy();
          expect(data.toString().includes('querySrv ENOTFOUND')).toEqual(true);
        });

        proc.on('exit', (code) => {
          expect(code).toBe(1);
          expect(spy).toHaveBeenCalled();
          done();
        });
      });

      it('run throws DNS SRV error and exits with code 1', (done) => {
        expect.assertions(3);
        proc = fork(exePath('run'), {
          env: {
            API_URL: apiUrl,
            LOGGER_MIN_SEVERITY: 'error',
            RABBITMQ_SRV_SERVICE_NAME: rabbitmqSrvServiceName,
            SERVICE_DISCOVERY_TIMEOUT: '1000',
            SERVICE_NAMES: ServiceNames.TxSubmit,
            USE_QUEUE: 'true'
          },
          stdio: 'pipe'
        });
        proc.stderr!.on('data', (data) => {
          spy();
          expect(data.toString().includes('querySrv ENOTFOUND')).toEqual(true);
        });
        proc.on('exit', (code) => {
          expect(code).toBe(1);
          expect(spy).toHaveBeenCalled();
          done();
        });
      });
    });

    describe('with unhealthy internal providers', () => {
      let spy: jest.Mock;
      beforeEach(() => {
        ogmiosServer = createUnhealthyMockOgmiosServer();
        spy = jest.fn();
      });

      it('cli:start-server exits with code 1', (done) => {
        expect.assertions(2);
        ogmiosServer.listen(ogmiosConnection.port, () => {
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              apiUrl,
              '--postgres-connection-string',
              postgresConnectionString,
              '--logger-min-severity',
              'error',
              '--ogmios-url',
              ogmiosConnection.address.webSocket,
              ServiceNames.StakePool,
              ServiceNames.TxSubmit
            ],
            {
              stdio: 'pipe'
            }
          );
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });
      });

      it('run exits with code 1', (done) => {
        expect.assertions(2);
        ogmiosServer.listen(ogmiosConnection.port, () => {
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              LOGGER_MIN_SEVERITY: 'error',
              OGMIOS_URL: ogmiosConnection.address.webSocket,
              POSTGRES_CONNECTION_STRING: postgresConnectionString,
              SERVICE_NAMES: `${ServiceNames.StakePool},${ServiceNames.TxSubmit}`
            },
            stdio: 'pipe'
          });
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });
      });
    });

    describe('specifying an unknown service', () => {
      let spy: jest.Mock;
      beforeEach(() => {
        ogmiosServer = createHealthyMockOgmiosServer();
        spy = jest.fn();
      });

      it('cli:start-server exits with code 1', (done) => {
        expect.assertions(2);
        ogmiosServer.listen(ogmiosConnection.port, () => {
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              apiUrl,
              '--ogmios-url',
              ogmiosConnection.address.webSocket,
              '--logger-min-severity',
              'error',
              'some-unknown-service',
              ServiceNames.TxSubmit
            ],
            {
              stdio: 'pipe'
            }
          );
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });
      });

      it('run exits with code 1', (done) => {
        expect.assertions(2);
        ogmiosServer.listen(ogmiosConnection.port, () => {
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              LOGGER_MIN_SEVERITY: 'error',
              OGMIOS_URL: ogmiosConnection.address.webSocket,
              SERVICE_NAMES: `some-unknown-service,${ServiceNames.TxSubmit}`
            },
            stdio: 'pipe'
          });
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            expect(spy).toHaveBeenCalled();
            done();
          });
        });
      });
    });
  });
});
