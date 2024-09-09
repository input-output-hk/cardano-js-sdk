import { BehaviorSubject, of } from 'rxjs';
import { BlockEntity, PgConnectionConfig } from '@cardano-sdk/projection-typeorm';
import { Milliseconds } from '@cardano-sdk/core';
import { TypeormService } from '../../src/util';
import { connStringToPgConnectionConfig } from '../../src';
import { createDatabase } from 'typeorm-extension';
import { dummyLogger as logger } from 'ts-log';

class TestTypeormService extends TypeormService {}

describe('TypeormService', () => {
  const badConnectionConfig: PgConnectionConfig = { port: 1234 };
  const connectionTimeout = Milliseconds(10);

  it('fails to start when it cannot connect to db', async () => {
    const service = new TestTypeormService('test', {
      connectionConfig$: of(badConnectionConfig),
      connectionTimeout,
      entities: [],
      logger
    });
    await service.initialize();
    await expect(service.start()).rejects.toThrowError();
  });

  describe('started', () => {
    const goodConnectionConfig = connStringToPgConnectionConfig(process.env.POSTGRES_CONNECTION_STRING_EMPTY!);
    let connectionConfig$: BehaviorSubject<PgConnectionConfig>;
    let service: TestTypeormService;

    beforeAll(async () => {
      await createDatabase({ options: { ...goodConnectionConfig, type: 'postgres' } });
    });

    beforeEach(async () => {
      connectionConfig$ = new BehaviorSubject(goodConnectionConfig);
      service = new TestTypeormService('test', {
        connectionConfig$,
        connectionTimeout,
        entities: [BlockEntity],
        logger
      });
      await service.initialize();
      await service.start();
    });

    it('does not create the schema', async () => {
      await expect(service.withQueryRunner((queryRunner) => queryRunner.hasTable('block'))).resolves.toBe(false);
    });

    it.skip('reconnects on error', async () => {
      connectionConfig$.next(badConnectionConfig);
      service.onError(new Error('Any error'));
      const queryResultReady = service.withQueryRunner(async () => 'ok');
      connectionConfig$.next(goodConnectionConfig);
      await expect(queryResultReady).resolves.toBe('ok');
    });

    it.skip('times out when it cannot reconnect for too long, then recovers', async () => {
      connectionConfig$.next(badConnectionConfig);
      service.onError(new Error('Any error'));
      const queryFailureReady = service.withQueryRunner(async () => 'ok');
      await expect(queryFailureReady).rejects.toThrowError();
      const querySuccessReady = service.withQueryRunner(async () => 'ok');
      connectionConfig$.next(goodConnectionConfig);

      // Allow the service to reconnect to the datasource with the new configuration
      await new Promise((resolve) => setTimeout(resolve, 1));

      await expect(querySuccessReady).resolves.toBe('ok');
    });
  });
});
