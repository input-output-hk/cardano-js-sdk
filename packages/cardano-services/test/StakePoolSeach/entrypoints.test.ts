import { ChildProcess, fork } from 'child_process';
import { getRandomPort } from 'get-port-please';
import { serverReady } from '../util';
import got from 'got';
import path from 'path';

const exePath = (name: 'cli' | 'run') => path.join(__dirname, '..', '..', 'dist', 'StakePoolSearch', `${name}.js`);

describe('entrypoints', () => {
  let apiPort: number;
  let apiUrlBase: string;
  let proc: ChildProcess;

  beforeEach(async () => {
    apiPort = await getRandomPort();
    apiUrlBase = `http://localhost:${apiPort}/stake-pool-search`;
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
    let dbConnectionString: string;

    beforeAll(async () => {
      dbConnectionString = 'postgresql://dbuser:secretpassword@database.server.com:3211/mydb';
    });

    describe('startup server with cli and run', () => {
      it('cli:start-server', async () => {
        proc = fork(exePath('cli'), [
          'start-server',
          '--api-url',
          `${apiUrlBase}`,
          '--logger-min-severity',
          'error',
          '--db-connection-string',
          `${dbConnectionString}`
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
            DB_CONNECTION_STRING: dbConnectionString,
            LOGGER_MIN_SEVERITY: 'error'
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
  });
});
