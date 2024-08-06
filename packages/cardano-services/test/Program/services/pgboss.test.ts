import {
  BlockEntity,
  PgConnectionConfig,
  STAKE_POOL_METADATA_QUEUE,
  createDataSource,
  createPgBossExtension
} from '@cardano-sdk/projection-typeorm';
import { Cardano } from '@cardano-sdk/core';
import { DataSource } from 'typeorm';
import { Observable, firstValueFrom } from 'rxjs';
import { PgBossHttpService, pgBossEntities } from '../../../src/Program/services/pgboss';
import { Pool } from 'pg';
import { StakePoolMetadataFetchMode } from '../../../src/Program/options';
import { WorkerHandlerFactoryOptions } from '../../../src/PgBoss';
import { getConnectionConfig, getPool } from '../../../src/Program/services/postgres';
import { logger } from '@cardano-sdk/util-dev';

const dnsResolver = () => Promise.resolve({ name: 'localhost', port: 5433, priority: 6, weight: 5 });

// Helpers to synchronize asynchronous tasks: the test, the job handler,
const handlerPromises: Promise<void>[] = [];
const handlerResolvers: (() => void)[] = [];
const testPromises: Promise<void>[] = [];
const testResolvers: (() => void)[] = [];
let callCounter = 0;

for (let i = 0; i < 4; ++i) {
  handlerPromises.push(new Promise<void>((resolve) => handlerResolvers.push(resolve)));
  testPromises.push(new Promise<void>((resolve) => testResolvers.push(resolve)));
}

jest.mock('../../../src/PgBoss/stakePoolMetadataHandler', () => ({
  stakePoolMetadataHandlerFactory: (options: WorkerHandlerFactoryOptions) => async () => {
    // eslint-disable-next-line @typescript-eslint/no-shadow
    const { logger } = options;
    // Wait for the "go command" for this attempt from the test
    await handlerPromises[callCounter];
    // Let the test know that pg-boss run this handler attempt
    setTimeout(testResolvers[callCounter], 100);

    logger.info('stakePoolMetadataHandler', callCounter);
    let err: Error;
    switch (callCounter++) {
      case 0:
        // On first attempt, throw an error to check PgBossHttpService (pg-boss) retries it
        throw new Error('test');
      case 1:
        // On second attempt, throw a 'mocked DB error' simulating a recoverable typeORM error
        // to check PgBossHttpService reconnect to the DB
        throw new Error('retry');
      case 2:
        // On third attempt, throw an error simulating the pgboss locked state
        // to check PgBossHttpService reconnect to the DB
        err = new Error('test');
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        (err as any).driverError = new Error('invalid message format');
        throw err;
      case 3:
        // On forth attempt, just finish with success
        break;
    }
  }
}));

// This makes the PgBossHttpService handle the error thrown by the handler on second attempt as an error which can be retried
jest.mock('@cardano-sdk/projection-typeorm', () => {
  const originalModule = jest.requireActual('@cardano-sdk/projection-typeorm');

  return { ...originalModule, isRecoverableTypeormError: (error: Error) => error.message === 'retry' };
});

describe('PgBossHttpService', () => {
  const apiUrl = new URL('http://unused/');
  let connectionConfig$: Observable<PgConnectionConfig>;
  let connectionConfig: PgConnectionConfig;
  let dataSource: DataSource;
  let db: Pool;
  let service: PgBossHttpService | undefined;

  beforeAll(async () => {
    const args = {
      postgresDbDbSync: process.env.POSTGRES_DB_DB_SYNC!,
      postgresDbStakePool: 'projection',
      postgresPasswordDbSync: process.env.POSTGRES_PASSWORD_DB_SYNC!,
      postgresPasswordStakePool: process.env.POSTGRES_PASSWORD_DB_SYNC!,
      postgresSrvServiceNameDbSync: process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC!,
      postgresSrvServiceNameStakePool: process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC!,
      postgresUserDbSync: process.env.POSTGRES_USER_DB_SYNC!,
      postgresUserStakePool: process.env.POSTGRES_USER_DB_SYNC!
    };

    connectionConfig$ = getConnectionConfig(dnsResolver, 'test', 'StakePool', args);
    connectionConfig = await firstValueFrom(connectionConfig$);

    const pool = await getPool(dnsResolver, logger, args);

    if (!pool) throw new Error("Can't connect to db-sync database");

    db = pool;
  });

  describe('without existing database', () => {
    describe('initialize', () => {
      it('throws an error and does not initialize pgboss schema', async () => {
        service = new PgBossHttpService(
          {
            apiUrl,
            dbCacheTtl: 0,
            lastRosEpochs: 10,
            metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
            parallelJobs: 3,
            queues: [],
            schedules: []
          },
          { connectionConfig$, db, logger }
        );
        await expect(async () => {
          await service!.initialize();
          await service!.start();
        }).rejects.toThrowError();
        const pool = new Pool({
          // most of the props are the same as for typeorm
          ...connectionConfig,
          ssl: undefined,
          user: connectionConfig.username
        });
        const pgbossSchema = await pool.query(
          "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'pgboss'"
        );
        expect(pgbossSchema.rowCount).toBe(0);
      });
    });
  });

  describe('with existing database', () => {
    beforeEach(async () => {
      dataSource = createDataSource({
        connectionConfig,
        devOptions: { dropSchema: true, synchronize: true },
        entities: pgBossEntities,
        extensions: { pgBoss: true },
        logger
      });
      await dataSource.initialize();
    });

    afterEach(async () => {
      await service?.shutdown();
      await dataSource.destroy().catch(() => void 0);
    });

    it('health check is ok after start with a valid db connection', async () => {
      service = new PgBossHttpService(
        {
          apiUrl,
          dbCacheTtl: 0,
          lastRosEpochs: 10,
          metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
          parallelJobs: 3,
          queues: [],
          schedules: []
        },
        { connectionConfig$, db, logger }
      );
      expect(await service.healthCheck()).toEqual({ ok: false, reason: 'PgBossHttpService not started' });
      await service.initialize();
      await service.start();
      expect(await service.healthCheck()).toEqual({ ok: true });
    });

    // eslint-disable-next-line max-statements
    it('retries a job until done, eventually reconnecting to the db', async () => {
      let observablePromise = Promise.resolve();
      // eslint-disable-next-line @typescript-eslint/no-empty-function, unicorn/consistent-function-scoping
      let observableResolver = () => {};
      let subscriptions = 0;

      const config$ = new Observable<PgConnectionConfig>((subscriber) => {
        subscriptions++;

        void (async () => {
          await observablePromise;
          subscriber.next(connectionConfig);
        })();
      });

      service = new PgBossHttpService(
        {
          apiUrl,
          dbCacheTtl: 0,
          lastRosEpochs: 10,
          metadataFetchMode: StakePoolMetadataFetchMode.DIRECT,
          parallelJobs: 3,
          queues: [STAKE_POOL_METADATA_QUEUE],
          schedules: []
        },
        { connectionConfig$: config$, db, logger }
      );
      await service.initialize();
      await service.start();

      // Insert test block with slot 1
      const queryRunner = dataSource.createQueryRunner();
      await queryRunner.connect();
      const blockRepos = dataSource.getRepository(BlockEntity);
      const block = { hash: 'test', height: 1, slot: 1 };
      await blockRepos.insert(block);

      // Helper to check all the status at each step
      const collectStatus = async () => ({ calls: callCounter, health: await service?.healthCheck(), subscriptions });

      expect(await collectStatus()).toEqual({ calls: 0, health: { ok: true }, subscriptions: 1 });

      // Schedule a job
      const pgboss = createPgBossExtension(queryRunner, logger);
      await pgboss.send(STAKE_POOL_METADATA_QUEUE, {}, { retryDelay: 1, retryLimit: 100, slot: Cardano.Slot(1) });
      await queryRunner.release();

      expect(await collectStatus()).toEqual({ calls: 0, health: { ok: true }, subscriptions: 1 });

      // Let the handler to throw an error which pg-boss will retry
      handlerResolvers[0]();
      await testPromises[0];

      expect(await collectStatus()).toEqual({ calls: 1, health: { ok: true }, subscriptions: 1 });

      // Prepare the DB configuration observable to wait for the command in order to provide a new connection config
      observablePromise = new Promise<void>((resolve) => (observableResolver = resolve));

      // Let the handler to throw a mocked DB error which should cause a DB reconnection
      handlerResolvers[1]();
      await testPromises[1];

      expect(await collectStatus()).toEqual({
        calls: 2,
        health: { ok: false, reason: 'DataBase error: reconnecting...' },
        subscriptions: 2
      });

      // Emit a new DB configuration to make PgBossHttpService reconnect
      observableResolver();

      // Wait until PgBossHttpService reconnected
      while (!(await service?.healthCheck())?.ok) await new Promise((resolve) => setTimeout(resolve, 5));

      expect(await collectStatus()).toEqual({ calls: 2, health: { ok: true }, subscriptions: 2 });

      // Prepare the DB configuration observable to wait for the command in order to provide a new connection config
      observablePromise = new Promise<void>((resolve) => (observableResolver = resolve));

      // Let the handler to throw an error simulating pgboss locked state which should cause a DB reconnection
      handlerResolvers[2]();
      await testPromises[2];

      expect(await collectStatus()).toEqual({
        calls: 3,
        health: { ok: false, reason: 'DataBase error: reconnecting...' },
        subscriptions: 3
      });

      // Emit a new DB configuration to make PgBossHttpService reconnect
      observableResolver();

      // Wait until PgBossHttpService reconnected
      while (!(await service?.healthCheck())?.ok) await new Promise((resolve) => setTimeout(resolve, 5));

      expect(await collectStatus()).toEqual({ calls: 3, health: { ok: true }, subscriptions: 3 });

      // Let the handler to complete with success
      handlerResolvers[3]();
      await testPromises[3];

      expect(await collectStatus()).toEqual({ calls: 4, health: { ok: true }, subscriptions: 3 });

      await dataSource.destroy();
    });
  });
});
