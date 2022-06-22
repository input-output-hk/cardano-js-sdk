/* eslint-disable sonarjs/no-identical-functions */
/* eslint-disable sonarjs/no-duplicate-string */
/* eslint-disable max-len */
import { ChildProcess, fork } from 'child_process';
import { Connection, ConnectionConfig, createConnectionObject } from '@cardano-ogmios/client';
import { RABBITMQ_URL_DEFAULT, ServiceNames } from '../src';
import { createHealthyMockOgmiosServer, createUnhealthyMockOgmiosServer, ogmiosServerReady, serverReady } from './util';
import { getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../src/util';
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
  let proc: ChildProcess;

  beforeEach(async () => {
    apiPort = await getRandomPort();
    apiUrl = `http://localhost:${apiPort}`;
  });

  afterEach(() => {
    if (proc !== undefined) proc.kill();
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
    let dbConnectionString: string;
    let ogmiosServer: http.Server;
    let ogmiosPort: ConnectionConfig['port'];
    let ogmiosConnection: Connection;
    let cardanoNodeConfigPath: string;
    let cacheTtl: string;

    beforeAll(async () => {
      ogmiosPort = await getRandomPort();
      ogmiosConnection = createConnectionObject({ port: ogmiosPort });
      dbConnectionString = process.env.DB_CONNECTION_STRING!;
      cardanoNodeConfigPath = process.env.CARDANO_NODE_CONFIG_PATH!;
      cacheTtl = process.env.CACHE_TTL!;
    });

    describe('with healthy internal providers', () => {
      describe('valid configuration', () => {
        beforeEach(async () => {
          ogmiosServer = createHealthyMockOgmiosServer();
          await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
          await ogmiosServerReady(ogmiosConnection);
        });

        afterEach(async () => {
          await serverClosePromise(ogmiosServer);
        });

        it('cli:start-server exposes a HTTP server at the configured URL with all services attached', async () => {
          proc = fork(exePath('cli'), [
            'start-server',
            '--api-url',
            apiUrl,
            '--db-connection-string',
            dbConnectionString,
            '--logger-min-severity',
            'error',
            '--ogmios-url',
            ogmiosConnection.address.webSocket,
            '--cardano-node-config-path',
            cardanoNodeConfigPath,
            '--cache-ttl',
            cacheTtl,
            ServiceNames.StakePool,
            ServiceNames.TxSubmit,
            ServiceNames.NetworkInfo,
            ServiceNames.Utxo
          ]);
          await assertServiceHealthy(apiUrl, ServiceNames.StakePool);
          await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
          await assertServiceHealthy(apiUrl, ServiceNames.NetworkInfo);
          await assertServiceHealthy(apiUrl, ServiceNames.Utxo);
        });

        it('run exposes a HTTP server at the configured URL with all services attached', async () => {
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrl,
              CACHE_TTL: cacheTtl,
              CARDANO_NODE_CONFIG_PATH: cardanoNodeConfigPath,
              DB_CONNECTION_STRING: dbConnectionString,
              LOGGER_MIN_SEVERITY: 'error',
              OGMIOS_URL: ogmiosConnection.address.webSocket,
              SERVICE_NAMES: `${ServiceNames.StakePool},${ServiceNames.TxSubmit},${ServiceNames.NetworkInfo},${ServiceNames.Utxo}`
            }
          });
          await assertServiceHealthy(apiUrl, ServiceNames.StakePool);
          await assertServiceHealthy(apiUrl, ServiceNames.TxSubmit);
          await assertServiceHealthy(apiUrl, ServiceNames.NetworkInfo);
          await assertServiceHealthy(apiUrl, ServiceNames.Utxo);
        });
      });

      describe('specifying a PostgreSQL-dependent service without providing the connection string', () => {
        let spy: jest.Mock;
        beforeEach(async () => {
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
              '--cache-ttl',
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
              CACHE_TTL: cacheTtlOutOfRange,
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

      describe('specifying a Cardano-Configurations-dependent service without providing the node config path', () => {
        let spy: jest.Mock;
        beforeEach(async () => {
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
              '--db-connection-string',
              dbConnectionString,
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
              DB_CONNECTION_STRING: dbConnectionString,
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
      });

      describe('specifying an Ogmios-dependent service without providing the Ogmios URL', () => {
        beforeEach(async () => {
          ogmiosServer = createHealthyMockOgmiosServer();
          // ws://localhost:1337
          ogmiosConnection = createConnectionObject();
          await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
          await ogmiosServerReady(ogmiosConnection);
        });

        afterEach(async () => {
          await serverClosePromise(ogmiosServer);
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

    describe('with unhealthy internal providers', () => {
      let spy: jest.Mock;
      beforeEach(async () => {
        ogmiosServer = createUnhealthyMockOgmiosServer();
        spy = jest.fn();
      });

      afterEach(async () => {
        await serverClosePromise(ogmiosServer);
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
              '--db-connection-string',
              dbConnectionString,
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
              DB_CONNECTION_STRING: dbConnectionString,
              LOGGER_MIN_SEVERITY: 'error',
              OGMIOS_URL: ogmiosConnection.address.webSocket,
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
      beforeEach(async () => {
        ogmiosServer = createHealthyMockOgmiosServer();
        spy = jest.fn();
      });

      afterEach(async () => {
        await serverClosePromise(ogmiosServer);
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
