/* eslint-disable unicorn/consistent-function-scoping */
import {
  BlockDataEntity,
  BlockEntity,
  TypeormStabilityWindowBuffer,
  connect,
  isRecoverableTypeormError,
  storeBlock,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../src';
import {
  Bootstrap,
  BootstrapExtraProps,
  ProjectionEvent,
  ProjectionOperator,
  requestNext
} from '@cardano-sdk/projection';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { ConnectionNotFoundError, DataSource, QueryFailedError, QueryRunner } from 'typeorm';
import { Observable, defer, firstValueFrom, lastValueFrom, map, of, take } from 'rxjs';
import { initializeDataSource } from '../util';
import { patchObject } from '@cardano-sdk/util';
import { shareRetryBackoff } from '@cardano-sdk/util-rxjs';

const { cardanoNode } = chainSyncData(ChainSyncDataSet.WithStakeKeyDeregistration);

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

describe('withTypeormTransaction', () => {
  let project$: Observable<Omit<ProjectionEvent, 'requestNext'>>;
  let buffer: TypeormStabilityWindowBuffer;
  let dataSource: DataSource;
  let queryRunner: QueryRunner;

  const createProjection = (dataSource$: Observable<DataSource>) =>
    jest.fn((evt$: Observable<ProjectionEvent>) =>
      evt$.pipe(
        withTypeormTransaction({
          connection$: dataSource$.pipe(connect({ logger }))
        }),
        storeBlock(),
        buffer.storeBlockData(),
        typeormTransactionCommit()
      )
    );

  beforeEach(async () => {
    dataSource = await initializeDataSource({ entities: [BlockEntity, BlockDataEntity] });
    queryRunner = dataSource.createQueryRunner();
  });

  afterEach(async () => {
    buffer.shutdown();
    await queryRunner.release();
    await dataSource.destroy();
  });

  describe('error handling when combined with shareRetryBackoff', () => {
    let numChainSyncSubscriptions: number;

    beforeEach(async () => {
      buffer = new TypeormStabilityWindowBuffer({ logger });
      await buffer.initialize(queryRunner);
    });

    const project = <PropsOut>(projection: ProjectionOperator<BootstrapExtraProps, PropsOut>) =>
      firstValueFrom(
        Bootstrap.fromCardanoNode({
          blocksBufferLength: 10,
          buffer,
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
          logger
        }).pipe(projection, requestNext())
      );

    beforeEach(() => (numChainSyncSubscriptions = 0));

    it('retries connection when it fails during operation', async () => {
      const dataSource$ = mockDataSource([failingToCommitDataSource(dataSource), dataSource]);
      const projection = createProjection(dataSource$);
      await project(shareRetryBackoff(projection));
      expect(numChainSyncSubscriptions).toBe(1);
      expect(projection).toBeCalledTimes(2);
    });

    it('retries initial connection opaquely', async () => {
      const dataSource$ = mockDataSource([failingToConnectDataSource(dataSource), dataSource]);
      const projection = createProjection(dataSource$);
      await project(shareRetryBackoff(projection));
      expect(numChainSyncSubscriptions).toBe(1);
      expect(projection).toBeCalledTimes(2);
    });
  });

  describe('with a successful database connection', () => {
    beforeEach(async () => {
      buffer = new TypeormStabilityWindowBuffer({
        allowNonSequentialBlockHeights: false,
        logger
      });
      await buffer.initialize(queryRunner);
      project$ = defer(() =>
        Bootstrap.fromCardanoNode({ blocksBufferLength: 10, buffer, cardanoNode, logger }).pipe(
          shareRetryBackoff(createProjection(of(dataSource)), { shouldRetry: isRecoverableTypeormError }),
          requestNext()
        )
      );
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

    it('does not retry unrecoverable errors', async () => {
      const lastEvent = await lastValueFrom(project$.pipe(take(2)));
      // deleting last block from the buffer creates an inconsistency: resumed projection will
      // try to insert a 'block' with an already existing 'height' which has a unique constraint.
      await queryRunner.manager.getRepository(BlockDataEntity).delete(lastEvent.block.header.blockNo);
      await buffer.initialize(queryRunner);
      // ADP-2807
      await expect(firstValueFrom(project$)).rejects.toThrowError(QueryFailedError);
    });
  });
});
