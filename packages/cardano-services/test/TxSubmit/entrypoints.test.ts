import { ChildProcess, fork } from 'child_process';
import { Connection, ConnectionConfig, createConnectionObject } from '@cardano-ogmios/client';
import { createMockOgmiosServer } from '@cardano-sdk/ogmios/test/mocks/mockOgmiosServer';
import { getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../../src/util';
import { serverReady } from '../util';
import got from 'got';
import http from 'http';
import path from 'path';

const exePath = (name: 'cli' | 'run') => path.join(__dirname, '..', '..', 'dist', 'TxSubmit', `${name}.js`);

describe('entrypoints', () => {
  let apiPort: number;
  let apiUrlBase: string;
  let proc: ChildProcess;

  beforeEach(async () => {
    apiPort = await getRandomPort();
    apiUrlBase = `http://localhost:${apiPort}`;
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

  // eslint-disable-next-line sonarjs/no-duplicate-string
  describe('start-server', () => {
    let ogmiosServer: http.Server;
    let ogmiosPort: ConnectionConfig['port'];
    let ogmiosConnection: Connection;
    let ogmiosUrl: string;

    beforeAll(async () => {
      ogmiosPort = await getRandomPort();
      ogmiosConnection = createConnectionObject({ port: ogmiosPort });
      ogmiosUrl = `ws://localhost:${ogmiosPort}`;
    });

    describe('running with a healthy Ogmios', () => {
      beforeEach(async () => {
        ogmiosServer = createMockOgmiosServer({
          healthCheck: { response: { networkSynchronization: 0.999, success: true } },
          submitTx: { response: { success: true } }
        });
        await listenPromise(ogmiosServer, { port: ogmiosConnection.port });
      });

      afterEach(async () => {
        await serverClosePromise(ogmiosServer);
      });

      it('cli:start-server', async () => {
        proc = fork(exePath('cli'), [
          'start-server',
          '--api-url',
          `${apiUrlBase}`,
          '--logger-min-severity',
          'error',
          '--ogmios-url',
          `${ogmiosUrl}`
        ]);
        await serverReady(apiUrlBase);
        const res = await got(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': 'application/json' }
        });
        expect(res.statusCode).toBe(200);
        expect(JSON.parse(res.body)).toEqual({ ok: true });
      });

      it('run', async () => {
        proc = fork(exePath('run'), {
          env: {
            API_URL: apiUrlBase,
            LOGGER_MIN_SEVERITY: 'error',
            OGMIOS_URL: ogmiosUrl
          }
        });
        await serverReady(apiUrlBase);
        const res = await got(`${apiUrlBase}/health`, {
          headers: { 'Content-Type': 'application/json' }
        });
        expect(res.statusCode).toBe(200);
        expect(JSON.parse(res.body)).toEqual({ ok: true });
      });
    });

    describe('startup if Ogmios is unhealthy', () => {
      let spy: jest.Mock;
      beforeEach(() => {
        ogmiosServer = createMockOgmiosServer({
          healthCheck: { response: { networkSynchronization: 0.8, success: true } },
          submitTx: { response: { success: false } }
        });
        spy = jest.fn();
      });
      it('cli:start-server', (done) => {
        ogmiosServer.listen(ogmiosConnection.port, () => {
          proc = fork(
            exePath('cli'),
            [
              'start-server',
              '--api-url',
              `${apiUrlBase}`,
              '--logger-min-severity',
              'error',
              '--ogmios-url',
              `${ogmiosUrl}`
            ],
            {
              stdio: 'pipe'
            }
          );
          proc.stderr!.on('data', spy);
          proc.on('exit', (code) => {
            expect(code).toBe(0);
            expect(spy).toHaveBeenCalled();
            done();
            ogmiosServer.close();
          });
        });
      });

      it('run', (done) => {
        ogmiosServer.listen(ogmiosConnection.port, () => {
          proc = fork(exePath('run'), {
            env: {
              API_URL: apiUrlBase,
              LOGGER_MIN_SEVERITY: 'error',
              OGMIOS_URL: ogmiosUrl
            },
            stdio: 'pipe'
          });
          proc.stderr!.on('data', spy);
          // eslint-disable-next-line sonarjs/no-identical-functions
          proc.on('exit', (code) => {
            expect(code).toBe(0);
            expect(spy).toHaveBeenCalled();
            done();
            ogmiosServer.close();
          });
        });
      });
    });
  });
});
