/* eslint-disable unicorn/consistent-function-scoping */
import { BlockEntity, createSinks, createSinksFactory } from '../src';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger, patchObject } from '@cardano-sdk/util-dev';
import { ConnectionNotFoundError, DataSource, IsNull, Not, QueryFailedError, QueryRunner } from 'typeorm';
import {
  Observable,
  Subject,
  combineLatest,
  defer,
  filter,
  firstValueFrom,
  lastValueFrom,
  map,
  of,
  take,
  takeWhile,
  toArray
} from 'rxjs';
import { ProjectionsEvent, SinksFactory, projectIntoSink } from '@cardano-sdk/projection';
import { initializeDataSource } from './connection';

const { cardanoNode, networkInfo } = chainSyncData(ChainSyncDataSet.WithStakeKeyDeregistration);

const stubDataSource = (baseDataSource: DataSource, queryRunnerStubs: Partial<QueryRunner>) =>
  patchObject(baseDataSource, {
    createQueryRunner: (mode) => patchObject(baseDataSource.createQueryRunner(mode), queryRunnerStubs)
  });

const failingToConnectDataSource = (baseDataSource: DataSource) =>
  stubDataSource(baseDataSource, {
    connect: () => Promise.reject<void>(new ConnectionNotFoundError('Connection error'))
  });

const failingToCommitDataSource = (baseDataSource: DataSource) =>
  stubDataSource(baseDataSource, {
    commitTransaction: () => Promise.reject<void>(new ConnectionNotFoundError('Connection error'))
  });

const mockDataSource = (dataSources: DataSource[]) => {
  const remainingDataSources = [...dataSources];
  return new Observable<DataSource>((observer) => {
    const nextDataSource = dataSources.shift();
    if (nextDataSource) {
      observer.next(nextDataSource);
      if (remainingDataSources.length === 0) {
        observer.complete();
      }
    } else {
      observer.error('Not enough data sources configured');
    }
  });
};

describe('createSinks', () => {
  let project$: Observable<ProjectionsEvent<{}>>;
  let dataSource: DataSource;
  let queryRunner: QueryRunner;
  let bufferTip$: Subject<Cardano.Block | 'origin'>;
  let bufferTail$: Subject<Cardano.Block | 'origin'>;

  const getBufferSize = () =>
    queryRunner.manager.count(BlockEntity, {
      cache: false,
      transaction: false,
      where: {
        // TODO: this does not work because it uses an argument from some previous query,
        // and instead of IS NOT NULL checks whether it's equal to specific block data bytes
        bufferData: Not(IsNull())
      }
    });
  const getNumBlocks = () => queryRunner.manager.count(BlockEntity);
  const recreateSubjects = () => {
    bufferTip$ = new Subject();
    bufferTail$ = new Subject();
  };
  const getHeader = (tipOrTail: Cardano.Block | 'origin') => (tipOrTail as Cardano.Block).header;

  beforeEach(async () => {
    dataSource = await initializeDataSource({});
    queryRunner = dataSource.createQueryRunner();
    recreateSubjects();
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
  });

  describe('error handling', () => {
    let numChainSyncSubscriptions: number;

    const project = (sinksFactory: SinksFactory<{}>) =>
      firstValueFrom(
        projectIntoSink({
          cardanoNode: patchObject(cardanoNode, {
            findIntersect: (points) =>
              cardanoNode.findIntersect(points).pipe(
                map((intersection) =>
                  patchObject(intersection, {
                    chainSync$: defer(() => {
                      numChainSyncSubscriptions++;
                      return intersection.chainSync$;
                    })
                  })
                )
              )
          }),
          logger,
          projections: {},
          sinksFactory
        })
      );

    beforeEach(() => (numChainSyncSubscriptions = 0));

    it('retries connection when it fails during operation', async () => {
      const dataSource$ = mockDataSource([failingToCommitDataSource(dataSource), dataSource]);
      const sinksFactory = jest.fn(
        createSinksFactory({
          dataSource$,
          logger
        })
      );
      await project(sinksFactory);
      expect(numChainSyncSubscriptions).toBe(1);
      expect(sinksFactory).toBeCalledTimes(1);
    });

    it('retries initial connection opaquely', async () => {
      const dataSource$ = mockDataSource([failingToConnectDataSource(dataSource), dataSource]);
      const sinksFactory = jest.fn(
        createSinksFactory({
          dataSource$,
          logger
        })
      );
      await project(sinksFactory);
      expect(numChainSyncSubscriptions).toBe(1);
      expect(sinksFactory).toBeCalledTimes(1);
    });
  });

  describe('with a successful database connection', () => {
    const securityParameter = 50;
    const compactBufferEveryNBlocks = 100;

    beforeEach(() => {
      const sinksFactory = () => {
        const sinks = createSinks({
          compactBufferEveryNBlocks,
          dataSource$: of(dataSource),
          logger
        });
        sinks.buffer.tip$.subscribe(bufferTip$);
        sinks.buffer.tail$.subscribe(bufferTail$);
        return sinks;
      };
      project$ = projectIntoSink({
        cardanoNode: {
          ...cardanoNode,
          genesisParameters$: of({
            ...networkInfo.genesisParameters,
            securityParameter
          })
        },
        logger,
        projections: {},
        sinksFactory
      });
    });

    it('is persistent', async () => {
      const {
        block: {
          header: { blockNo }
        }
      } = await lastValueFrom(project$.pipe(take(2)));
      const {
        block: {
          header: { blockNo: resubscribedNextBlockNo }
        }
      } = await firstValueFrom(project$);
      expect(resubscribedNextBlockNo).toEqual(blockNo + 1);
    });

    it.skip('does not retry unrecoverable errors', async () => {
      const lastEvent = await lastValueFrom(project$.pipe(take(2)));
      // deleting last block from the buffer creates an inconsistency: resumed projection will
      // try to insert a 'block' with an already existing 'hash' which has a unique constraint.
      await queryRunner.manager.query(
        `DELETE FROM block_data WHERE block_id IN (SELECT id FROM block WHERE hash='${lastEvent.block.header.hash}')`
      );
      // ADP-2807
      await expect(firstValueFrom(project$)).rejects.toThrowError(QueryFailedError);
    });

    describe('buffer', () => {
      // eslint-disable-next-line unicorn/consistent-function-scoping
      describe('when there are no blocks in the buffer', () => {
        it('emits "origin" for both tip and tail', async () => {
          const subscription = project$.subscribe();
          const [tip, tail] = await firstValueFrom(combineLatest([bufferTip$, bufferTail$]));
          // subscribe to initialize the observable,
          // but don't wait for it to emit any events
          subscription.unsubscribe();
          expect(tip).toEqual('origin');
          expect(tail).toEqual('origin');
        });
      });

      describe('with 1 block in the buffer', () => {
        it('emits that block as both tip$ and tail$', async () => {
          const lastTipAndTail = lastValueFrom(combineLatest([bufferTip$, bufferTail$]));
          await firstValueFrom(project$);
          const [tip, tail] = await lastTipAndTail;
          expect(typeof tip).toEqual('object');
          expect(tail).toEqual(tip);
        });
      });

      describe('with 3 blocks in the buffer', () => {
        it('emits tip$ for every new block, tail$ only for origin and the 1st block', async () => {
          const tipsReady = firstValueFrom(bufferTip$.pipe(toArray()));
          const tailsReady = firstValueFrom(bufferTail$.pipe(toArray()));
          await lastValueFrom(project$.pipe(take(3)));
          const bufferSize = await getBufferSize();
          expect(bufferSize).toEqual(3);
          const tips = await tipsReady;
          expect(tips.length).toEqual(4);
          expect(tips[0]).toEqual('origin');
          expect(getHeader(tips[1]).hash).not.toEqual(getHeader(tips[2]).hash);
          expect(getHeader(tips[2]).hash).not.toEqual(getHeader(tips[3]).hash);
          const tails = await tailsReady;
          expect(tails.length).toEqual(2);
          expect(tails[0]).toEqual('origin');
          expect(getHeader(tails[1]).hash).toEqual(getHeader(tips[1]).hash);
        });
      });

      it('rollback pops the tip$', async () => {
        const tipsReady = firstValueFrom(bufferTip$.pipe(toArray()));
        await firstValueFrom(project$.pipe(filter(({ eventType }) => eventType === ChainSyncEventType.RollBackward)));
        const tips = await tipsReady;
        expect(getHeader(tips[tips.length - 1]).blockNo).toBeLessThan(getHeader(tips[tips.length - 2]).blockNo);
      });

      it('clears old block_data every 100 blocks and emits new tail$', async () => {
        const preClearTail = lastValueFrom(bufferTail$);
        await lastValueFrom(
          project$.pipe(
            // stop one block before the expected clear
            takeWhile(
              ({
                block: {
                  header: { blockNo }
                }
              }) => (blockNo + 1) % compactBufferEveryNBlocks !== 0
            )
          )
        );
        const preClearBufferSize = await getBufferSize();
        const preClearNumBlocks = await getNumBlocks();
        recreateSubjects();
        const postClearTail = lastValueFrom(bufferTail$);
        // next event should trigger the clear
        await firstValueFrom(project$);
        expect(await getBufferSize()).toBeLessThan(preClearBufferSize);
        expect(await getNumBlocks()).toEqual(preClearNumBlocks + 1);
        const preClearTailHeight = getHeader(await preClearTail).blockNo;
        const postClearTailHeight = getHeader(await postClearTail).blockNo;
        expect(postClearTailHeight).toBeGreaterThan(preClearTailHeight);
      });
    });
  });
});
