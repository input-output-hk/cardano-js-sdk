import {
  BlockEntity,
  PgConnectionConfig,
  STAKE_POOL_METADATA_QUEUE,
  createPgBossExtension
} from '@cardano-sdk/projection-typeorm';
import { Cardano } from '@cardano-sdk/core';
import { DataSource } from 'typeorm';
import { Observable, firstValueFrom } from 'rxjs';
import { PgBossHttpService, pgBossEntities } from '../../../src/Program/services/pgboss';
import { Pool } from 'pg';
import { WorkerHandlerFactoryOptions } from '../../../src/PgBoss';
import { createObservableDataSource } from '../../../src';
import { getConnectionConfig, getPool } from '../../../src/Program/services/postgres';
import { logger } from '@cardano-sdk/util-dev';

const dnsResolver = () => Promise.resolve({ name: 'localhost', port: 5433, priority: 6, weight: 5 });

// Helpers to synchronize asynchronous tasks: the test, the job handler,
const handlerPromises: Promise<void>[] = [];
const handlerResolvers: (() => void)[] = [];
const testPromises: Promise<void>[] = [];
const testResolvers: (() => void)[] = [];
let callCounter = 0;

for (let i = 0; i < 3; ++i) {
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
    switch (callCounter++) {
      case 0:
        // On first attempt, throw an error to check PgBossHttpService (pg-boss) retries it
        throw new Error('test');
      case 1:
        // On second attempt, throw a 'mocked DB error' error to check PgBossHttpService reconnect to the DB
        throw new Error('retry');
      case 2:
        // On third attempt, just finish with success
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
  let connectionConfig$: Observable<PgConnectionConfig>;
  let dataSource: DataSource;
  let db: Pool;
  let service: PgBossHttpService | undefined;

  beforeAll(async () => {
    const args = {
      postgresDbDbSync: process.env.POSTGRES_DB_DB_SYNC!,
      postgresDbStakePool: process.env.POSTGRES_DB_STAKE_POOL!,
      postgresPasswordDbSync: process.env.POSTGRES_PASSWORD_DB_SYNC!,
      postgresPasswordStakePool: process.env.POSTGRES_PASSWORD_DB_SYNC!,
      postgresSrvServiceNameDbSync: process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC!,
      postgresSrvServiceNameStakePool: process.env.POSTGRES_SRV_SERVICE_NAME_DB_SYNC!,
      postgresUserDbSync: process.env.POSTGRES_USER_DB_SYNC!,
      postgresUserStakePool: process.env.POSTGRES_USER_DB_SYNC!
    };

    connectionConfig$ = getConnectionConfig(dnsResolver, 'test', args);
    const dataSource$ = createObservableDataSource({
      connectionConfig$,
      devOptions: { dropSchema: true, synchronize: true },
      entities: pgBossEntities,
      extensions: { pgBoss: true },
      logger,
      migrationsRun: false
    });
    dataSource = await firstValueFrom(dataSource$);

    const pool = await getPool(dnsResolver, logger, args);

    if (!pool) throw new Error("Can't connect to db-sync database");

    db = pool;
  });

  afterEach(async () => {
    await service?.shutdown();
  });

  it('health check is ok after start with a valid db connection', async () => {
    service = new PgBossHttpService({ parallelJobs: 3, queues: [] }, { connectionConfig$, db, logger });
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

    const connectionConfig = await firstValueFrom(connectionConfig$);
    const config$ = new Observable<PgConnectionConfig>((subscriber) => {
      subscriptions++;

      void (async () => {
        await observablePromise;
        subscriber.next(connectionConfig);
      })();
    });

    service = new PgBossHttpService(
      { parallelJobs: 3, queues: [STAKE_POOL_METADATA_QUEUE] },
      { connectionConfig$: config$, db, logger }
    );
    await service.initialize();
    await service.start();

    // Insert test block with slot 1
    const blockRepos = dataSource.getRepository(BlockEntity);
    const block = { hash: 'test', height: 1, slot: 1 };
    await blockRepos.insert(block);

    // Helper to check all the status at each step
    const collectStatus = async () => ({ calls: callCounter, health: await service?.healthCheck(), subscriptions });

    expect(await collectStatus()).toEqual({ calls: 0, health: { ok: true }, subscriptions: 1 });

    // Schedule a job
    const queryRunner = dataSource.createQueryRunner();
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

    // Let the handler to complete with success
    handlerResolvers[2]();
    await testPromises[2];

    expect(await collectStatus()).toEqual({ calls: 3, health: { ok: true }, subscriptions: 2 });
  });
});
