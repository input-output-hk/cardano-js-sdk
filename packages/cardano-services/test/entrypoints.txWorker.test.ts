/* eslint-disable sonarjs/no-duplicate-string */
import { BAD_CONNECTION_URL } from '../../rabbitmq/test/utils';
import { ChildProcess, fork } from 'child_process';
import { Ogmios } from '@cardano-sdk/ogmios';
import { RabbitMQContainer } from '../../rabbitmq/test/docker';
import { createHealthyMockOgmiosServer, ogmiosServerReady } from './util';
import { getRandomPort } from 'get-port-please';
import { listenPromise, serverClosePromise } from '../src/util';
import { logger } from '@cardano-sdk/util-dev';
import http from 'http';
import path from 'path';

const exePath = (name: 'cli') => path.join(__dirname, '..', 'dist', 'cjs', `${name}.js`);

describe('tx-worker entrypoints', () => {
  const container = new RabbitMQContainer();

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
  // eslint-disable-next-line sonarjs/cognitive-complexity
  describe('cli:start-worker with a working RabbitMQ server', () => {
    describe('transaction are actually submitted', () => {
      it('submits transactions using CLI options', async () => {
        hookPromise = new Promise((resolve) => (hook = resolve));
        proc = fork(exePath('cli'), commonArgs, { env: {}, stdio: 'pipe' });
        await Promise.all([hookPromise, container.enqueueTx(logger)]);
      });

      it('submits transactions using env variables', async () => {
        hookPromise = new Promise((resolve) => (hook = resolve));
        proc = fork(exePath('cli'), ['start-worker'], { env: commonEnv, stdio: 'pipe' });
        await Promise.all([hookPromise, container.enqueueTx(logger)]);
      });
    });

    describe('parallel option', () => {
      describe('without parallel option', () => {
        it('starts in serial mode', (done) => {
          proc = fork(exePath('cli'), commonArgs, { env: {}, stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
        });

        it('starts in serial mode', (done) => {
          proc = fork(exePath('cli'), ['start-worker'], { env: commonEnv, stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
        });
      });

      describe('with bad parallel option', () => {
        it('exits with code 1 using CLI options', (done) => {
          expect.assertions(2);
          proc = fork(exePath('cli'), [...commonArgs, '--parallel', 'test'], { env: {}, stdio: 'pipe' });
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
          proc = fork(exePath('cli'), ['start-worker'], { env: { ...commonEnv, PARALLEL: 'test' }, stdio: 'pipe' });
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
          proc = fork(exePath('cli'), [...commonArgs, '--parallel', 'false'], { env: {}, stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
        });

        it('worker starts in serial mode using env variables', (done) => {
          proc = fork(exePath('cli'), ['start-worker'], { env: { ...commonEnv, PARALLEL: 'false' }, stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('serial mode') ? done() : null));
        });
      });

      describe('with parallel option set to true', () => {
        it('worker starts in parallel mode using CLI options', (done) => {
          proc = fork(exePath('cli'), [...commonArgs, '--parallel', 'true'], { env: {}, stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('parallel mode') ? done() : null));
        });

        it('worker starts in parallel mode using env variables', (done) => {
          proc = fork(exePath('cli'), ['start-worker'], { env: { ...commonEnv, PARALLEL: 'true' }, stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('parallel mode') ? done() : null));
        });
      });

      describe('default parallel option value', () => {
        it('worker starts in parallel mode using CLI options', (done) => {
          proc = fork(exePath('cli'), [...commonArgs, '--parallel'], { env: {}, stdio: 'pipe' });
          proc.stdout!.on('data', (data) => (data.toString().match('parallel mode') ? done() : null));
        });
      });
    });
  });

  describe('without a working RabbitMQ server handles a connection error event', () => {
    it('exits with code 1 using CLI options', (done) => {
      expect.assertions(2);
      proc = fork(exePath('cli'), [...commonArgs, '--rabbitmq-url', BAD_CONNECTION_URL.toString()], {
        env: {},
        stdio: 'pipe'
      });

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
      proc = fork(exePath('cli'), ['start-worker'], {
        env: { ...commonEnv, RABBITMQ_URL: BAD_CONNECTION_URL.toString() },
        stdio: 'pipe'
      });

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
      proc = fork(exePath('cli'), commonArgsWithServiceDiscovery, { env: {}, stdio: 'pipe' });

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
      proc = fork(exePath('cli'), ['start-worker'], { env: commonEnvWithServiceDiscovery, stdio: 'pipe' });

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
