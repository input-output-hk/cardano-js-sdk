import { BaseProjectionEvent } from '@cardano-sdk/projection';
import {
  BlockEntity,
  TypeormConnection,
  TypeormTipTracker,
  createObservableConnection,
  createTypeormTipTracker
} from '../src';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { DataSource, NoConnectionForRepositoryError, QueryRunner, Repository } from 'typeorm';
import { Observable, firstValueFrom, of, throwError } from 'rxjs';
import { RetryBackoffConfig } from 'backoff-rxjs';
import { connectionConfig$, createBlockEntity, createBlockHeader, initializeDataSource } from './util';
import { createStubObservable, logger } from '@cardano-sdk/util-dev';

const stubSingleEventProjection = (eventType: ChainSyncEventType, header: Cardano.PartialBlockHeader) =>
  of({
    block: { header },
    eventType
  } as BaseProjectionEvent);

describe('createTypeormTipTracker', () => {
  const entities = [BlockEntity];
  const retryBackoffConfig: RetryBackoffConfig = { initialInterval: 1 };

  let dataSource: DataSource;
  let queryRunner: QueryRunner;
  let connection$: Observable<TypeormConnection>;
  let blockRepo: Repository<BlockEntity>;
  let tipTracker: TypeormTipTracker;

  beforeEach(async () => {
    dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    blockRepo = queryRunner.manager.getRepository(BlockEntity);
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
  });

  describe('with successful connection', () => {
    beforeEach(() => {
      connection$ = createObservableConnection({
        connectionConfig$,
        entities,
        logger
      });
    });

    describe('when there are no blocks in the buffer', () => {
      beforeEach(() => {
        tipTracker = createTypeormTipTracker({ connection$, reconnectionConfig: retryBackoffConfig });
      });

      it('tip$ emits "origin"', async () => {
        await expect(firstValueFrom(tipTracker.tip$)).resolves.toBe('origin');
      });

      describe('piping a block through returned operator', () => {
        it('tip$ emits new block', async () => {
          const header = createBlockHeader(1);
          await firstValueFrom(
            stubSingleEventProjection(ChainSyncEventType.RollForward, header).pipe(tipTracker.trackProjectedTip())
          );
          await expect(firstValueFrom(tipTracker.tip$)).resolves.toEqual(header);
        });
      });
    });

    describe('with 1 block in the buffer', () => {
      let header: Cardano.PartialBlockHeader;

      beforeEach(async () => {
        header = createBlockHeader(1);
        await blockRepo.insert(createBlockEntity(header));
        tipTracker = createTypeormTipTracker({ connection$, reconnectionConfig: retryBackoffConfig });
      });

      it('tip$ emits that block', async () => {
        await expect(firstValueFrom(tipTracker.tip$)).resolves.toEqual(header);
      });

      describe('rolling back that block', () => {
        it('tip$ emits "origin"', async () => {
          await blockRepo.delete(header.slot);
          await firstValueFrom(
            stubSingleEventProjection(ChainSyncEventType.RollBackward, header).pipe(tipTracker.trackProjectedTip())
          );
          await expect(firstValueFrom(tipTracker.tip$)).resolves.toBe('origin');
        });
      });

      describe('piping a block through returned operator', () => {
        it('tip$ emits new block', async () => {
          const newBlockHeader = createBlockHeader(2);
          await firstValueFrom(
            of({
              block: { header: newBlockHeader },
              eventType: ChainSyncEventType.RollForward
            } as BaseProjectionEvent).pipe(tipTracker.trackProjectedTip())
          );
          await expect(firstValueFrom(tipTracker.tip$)).resolves.toEqual(newBlockHeader);
        });
      });
    });

    describe('with 2 blocks in the buffer', () => {
      let header1: Cardano.PartialBlockHeader;
      let header2: Cardano.PartialBlockHeader;

      beforeEach(async () => {
        header1 = createBlockHeader(1);
        header2 = createBlockHeader(2);
        await blockRepo.insert([createBlockEntity(header1), createBlockEntity(header2)]);
        tipTracker = createTypeormTipTracker({ connection$, reconnectionConfig: retryBackoffConfig });
      });

      // TODO LW-9971
      it.skip('tip$ emits latest block', async () => {
        await expect(firstValueFrom(tipTracker.tip$)).resolves.toEqual(header2);
      });

      describe('rolling back latest block', () => {
        it('tip$ emits first block', async () => {
          await blockRepo.delete(header2.slot);
          await firstValueFrom(
            stubSingleEventProjection(ChainSyncEventType.RollBackward, header2).pipe(tipTracker.trackProjectedTip())
          );
          await expect(firstValueFrom(tipTracker.tip$)).resolves.toEqual(header1);
        });
      });
    });
  });

  describe('with failing connection', () => {
    it('reconnects and eventually emits the tip', async () => {
      connection$ = createStubObservable(
        throwError(() => new NoConnectionForRepositoryError('conn')),
        createObservableConnection({
          connectionConfig$,
          entities,
          logger
        })
      );
      const header = createBlockHeader(1);
      await blockRepo.insert(createBlockEntity(header));
      tipTracker = createTypeormTipTracker({ connection$, reconnectionConfig: retryBackoffConfig });

      await expect(firstValueFrom(tipTracker.tip$)).resolves.toEqual(header);
    });
  });
});
