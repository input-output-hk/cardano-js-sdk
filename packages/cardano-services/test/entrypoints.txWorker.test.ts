/* eslint-disable sonarjs/no-duplicate-string */
import { BAD_CONNECTION_URL, enqueueFakeTx, removeAllMessagesFromQueue } from '../../rabbitmq/test/utils';
import { ChildProcess, fork } from 'child_process';
import { createConnectionObject } from '@cardano-ogmios/client';
import { createHealthyMockOgmiosServer, ogmiosServerReady } from './util';
import { getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../src/util';
import http from 'http';
import path from 'path';

const exePath = (name: 'cli' | 'startWorker') => path.join(__dirname, '..', 'dist', 'cjs', `${name}.js`);

describe('tx-worker entrypoints', () => {
  let commonArgs: string[];
  let commonEnv: Record<string, string>;
  let hook: () => void;
  let hookLogs: string[];
  let hookPromise: Promise<void>;
  let loggerHookCounter: number;
  let ogmiosServer: http.Server;
  let proc: ChildProcess;

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
    const ogmiosConnection = createConnectionObject({ port });
    ogmiosServer = createHealthyMockOgmiosServer(() => hook());
    await listenPromise(ogmiosServer, { port });
    await ogmiosServerReady(ogmiosConnection);
    commonArgs = ['start-worker', '--logger-min-severity', 'error', '--ogmios-url', ogmiosConnection.address.webSocket];
    commonEnv = { LOGGER_MIN_SEVERITY: 'error', OGMIOS_URL: ogmiosConnection.address.webSocket };
  });

  afterAll(async () => await serverClosePromise(ogmiosServer));

  beforeEach(async () => {
    await removeAllMessagesFromQueue();
    await enqueueFakeTx();
    await enqueueFakeTx();
    hookLogs = [];
    loggerHookCounter = 0;
  });

  afterEach((done) => {
    resetHook();
    if (proc?.kill()) proc.on('close', done);
    else done();
  });

  // Tests without any assertion fail if they get timeout
  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('with a working RabbitMQ server', () => {
    describe('worker starts', () => {
      it('cli:start-worker', (done) => {
        proc = fork(exePath('cli'), commonArgs, { stdio: 'pipe' });
        proc.stdout!.on('data', (data) => (data.toString().match('RabbitMQ transactions worker') ? done() : null));
      });

      it('startWorker', (done) => {
        hook = done;
        proc = fork(exePath('startWorker'), { env: commonEnv, stdio: 'pipe' });
      });
    });

    describe('transaction are actually submitted', () => {
      it('cli:start-worker submits transactions', () =>
        new Promise<void>(async (resolve) => {
          hook = resolve;
          proc = fork(exePath('cli'), commonArgs, { stdio: 'pipe' });
        }));

      it('startWorker submits transactions', () =>
        new Promise<void>(async (resolve) => {
          hook = resolve;
          proc = fork(exePath('startWorker'), { env: commonEnv, stdio: 'pipe' });
        }));
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
          await hookPromise;
          expect(hookLogs).toEqual(['Processing tx 1', 'Processed tx 1', 'Processing tx 2', 'Processed tx 2']);
        });
      });

      describe('with bad parallel option', () => {
        it('cli:start-worker exits with code 1', (done) => {
          expect.assertions(2);
          proc = fork(exePath('cli'), [...commonArgs, '--parallel', 'test'], { stdio: 'pipe' });
          proc.stderr!.on('data', (data) =>
            expect(data.toString()).toMatch('tx-submit requires a valid Parallel mode')
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
          await hookPromise;
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
          await hookPromise;
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
});
