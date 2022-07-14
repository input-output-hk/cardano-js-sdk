/* eslint-disable sonarjs/no-duplicate-string */
import { BAD_CONNECTION_URL, enqueueFakeTx, removeAllQueues } from '../../rabbitmq/test/utils';
import { ChildProcess, fork } from 'child_process';
import { Ogmios } from '@cardano-sdk/ogmios';
import { createHealthyMockOgmiosServer, ogmiosServerReady } from './util';
import { getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../src/util';
import http from 'http';
import path from 'path';

const exePath = (name: 'cli' | 'startWorker') => path.join(__dirname, '..', 'dist', 'cjs', `${name}.js`);

describe('tx-worker entrypoints', () => {
  let commonArgs: string[];
  let commonArgsWithServiceDiscovery: string[];
  let commonEnv: Record<string, string>;
  let commonEnvWithServiceDiscovery: Record<string, string>;
  let hook: () => void;
  let hookLogs: string[];
  let hookPromise: Promise<void>;
  let loggerHookCounter: number;
  let ogmiosServer: http.Server;
  let proc: ChildProcess;
  let rabbitmqSrvServiceName: string;
  let ogmiosSrvServiceName: string;

  const resetHook = () => (hook = jest.fn());

  const loggerHook = (): [() => void, Promise<void>] => {
    let resolver: () => void;

    const promise = new Promise<void>((resolve) => (resolver = resolve));
    const loggingHook = async () => {
      const counter = ++loggerHookCounter;

      hookLogs.push(`Processing tx ${counter}`);
      await new Promise((resolve) => setTimeout(resolve, 100));
      hookLogs.push(`Processed tx ${counter}`);
      if (counter === 2) resolver();
    };

    return [loggingHook, promise];
  };

  beforeAll(async () => {
    resetHook();
    const port = await getRandomPort();
    const ogmiosConnection = Ogmios.createConnectionObject({ port });
    ogmiosServer = createHealthyMockOgmiosServer(() => hook());
    rabbitmqSrvServiceName = process.env.RABBITMQ_SRV_SERVICE_NAME!;
    ogmiosSrvServiceName = process.env.OGMIOS_SRV_SERVICE_NAME!;
    await listenPromise(ogmiosServer, { port });
    await ogmiosServerReady(ogmiosConnection);
    commonArgs = ['start-worker', '--logger-min-severity', 'error', '--ogmios-url', ogmiosConnection.address.webSocket];
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
    commonEnv = { LOGGER_MIN_SEVERITY: 'error', OGMIOS_URL: ogmiosConnection.address.webSocket };
    commonEnvWithServiceDiscovery = {
      LOGGER_MIN_SEVERITY: 'error',
      OGMIOS_SRV_SERVICE_NAME: ogmiosSrvServiceName,
      RABBITMQ_SRV_SERVICE_NAME: rabbitmqSrvServiceName,
      SERVICE_DISCOVERY_TIMEOUT: '1000'
    };
  });

  afterAll(async () => await serverClosePromise(ogmiosServer));

  beforeEach(async () => {
    await removeAllQueues();
    hookLogs = [];
    loggerHookCounter = 0;
  });

  afterEach((done) => {
    resetHook();
    if (proc?.kill()) proc.on('close', () => done());
    else done();
  });

  // Tests without any assertion fail if they get timeout
  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('with a working RabbitMQ server', () => {
    describe('transaction are actually submitted', () => {
      it('cli:start-worker submits transactions', async () => {
        hookPromise = new Promise((resolve) => (hook = resolve));
        proc = fork(exePath('cli'), commonArgs, { stdio: 'pipe' });
        await Promise.all([hookPromise, enqueueFakeTx()]);
      });

      it('startWorker submits transactions', async () => {
        hookPromise = new Promise((resolve) => (hook = resolve));
        proc = fork(exePath('startWorker'), { env: commonEnv, stdio: 'pipe' });
        await Promise.all([hookPromise, enqueueFakeTx()]);
      });
    });

    describe('parallel option', () => {
      describe('without parallel option', () => {
        it('cli:start-worker starts in serial mode', (done) => {
          proc = fork(exePath('cli'), commonArgs, { stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
        });

        it('startWorker starts in serial mode', async () => {
          [hook, hookPromise] = loggerHook();
          proc = fork(exePath('startWorker'), { env: commonEnv, stdio: 'pipe' });
          const txPromises = [enqueueFakeTx(0), enqueueFakeTx(1)];
          await hookPromise;
          await Promise.all(txPromises);
          expect(hookLogs).toEqual(['Processing tx 1', 'Processed tx 1', 'Processing tx 2', 'Processed tx 2']);
        });
      });

      describe('with bad parallel option', () => {
        it('cli:start-worker exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(exePath('cli'), [...commonArgs, '--parallel', 'test'], { stdio: 'pipe' });
          proc.stderr!.on('data', (data) =>
            expect(data.toString()).toMatch('RabbitMQ worker requires a valid Parallel mode')
          );
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            done();
          });
        });

        it('startWorker exits with code 1', (done) => {
          expect.assertions(1);
          proc = fork(exePath('startWorker'), { env: { ...commonEnv, PARALLEL: 'test' }, stdio: 'pipe' });
          proc.on('exit', (code) => {
            expect(code).toBe(1);
            done();
          });
        });
      });

      describe('with parallel option set to false', () => {
        it('worker starts in serial mode', (done) => {
          proc = fork(exePath('cli'), [...commonArgs, '--parallel', 'false'], { stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
        });

        it('startWorker starts in serial mode', async () => {
          [hook, hookPromise] = loggerHook();
          proc = fork(exePath('startWorker'), { env: { ...commonEnv, PARALLEL: 'false' }, stdio: 'pipe' });
          const txPromises = [enqueueFakeTx(0), enqueueFakeTx(1)];
          await hookPromise;
          await Promise.all(txPromises);
          expect(hookLogs).toEqual(['Processing tx 1', 'Processed tx 1', 'Processing tx 2', 'Processed tx 2']);
        });
      });

      describe('with parallel option set to true', () => {
        it('worker starts in parallel mode', (done) => {
          proc = fork(exePath('cli'), [...commonArgs, '--parallel', 'true'], { stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('parallel mode') ? done() : null));
        });

        it('startWorker starts in parallel mode', async () => {
          [hook, hookPromise] = loggerHook();
          proc = fork(exePath('startWorker'), { env: { ...commonEnv, PARALLEL: 'true' }, stdio: 'pipe' });
          const txPromises = [enqueueFakeTx(0), enqueueFakeTx(1)];
          await hookPromise;
          await Promise.all(txPromises);
          expect(hookLogs).toEqual(['Processing tx 1', 'Processing tx 2', 'Processed tx 1', 'Processed tx 2']);
        });
      });

      describe('default parallel option value', () => {
        it('worker starts in parallel mode', (done) => {
          proc = fork(exePath('cli'), [...commonArgs, '--parallel'], { stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('parallel mode') ? done() : null));
        });
      });
    });
  });

  describe('without a working RabbitMQ server', () => {
    it('cli:start-worker exits with code 1', (done) => {
      expect.assertions(2);
      proc = fork(exePath('cli'), [...commonArgs, '--rabbitmq-url', BAD_CONNECTION_URL.toString()], { stdio: 'pipe' });
      proc.stderr!.on('data', (data) => expect(data.toString()).toMatch('ECONNREFUSED'));
      proc.on('exit', (code) => {
        expect(code).toBe(1);
        done();
      });
    });

    it('startWorker exits with code 1', (done) => {
      expect.assertions(1);
      proc = fork(exePath('startWorker'), {
        env: { ...commonEnv, RABBITMQ_URL: BAD_CONNECTION_URL.toString() },
        stdio: 'pipe'
      });
      proc.on('exit', (code) => {
        expect(code).toBe(1);
        done();
      });
    });
  });

  describe('with service discovery', () => {
    it('cli:start-worker throws DNS SRV error and exits with code 1', (done) => {
      expect.assertions(2);
      proc = fork(exePath('cli'), commonArgsWithServiceDiscovery, { stdio: 'pipe' });

      proc.stderr!.on('data', (data) => {
        expect(data.toString().includes('querySrv ENOTFOUND')).toEqual(true);
      });

      proc.on('exit', (code) => {
        expect(code).toBe(1);
        done();
      });
    });

    it('startWorker throws DNS SRV error and exits with code 1', (done) => {
      expect.assertions(2);
      proc = fork(exePath('startWorker'), {
        env: commonEnvWithServiceDiscovery,
        stdio: 'pipe'
      });
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
