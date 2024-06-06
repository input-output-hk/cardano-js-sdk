/* eslint-disable unicorn/consistent-function-scoping */
import {
  BlockDataEntity,
  BlockEntity,
  connect,
  isRecoverableTypeormError,
  storeBlock,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../src/index.js';
import { Bootstrap, requestNext } from '@cardano-sdk/projection';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { ConnectionNotFoundError, QueryFailedError } from 'typeorm';
import { Observable, defer, firstValueFrom, lastValueFrom, map, of, take, toArray } from 'rxjs';
import { createProjectorContext } from './util.js';
import { initializeDataSource } from '../util.js';
import { patchObject } from '@cardano-sdk/util';
import { shareRetryBackoff } from '@cardano-sdk/util-rxjs';
import type { BootstrapExtraProps, ProjectionEvent, ProjectionOperator } from '@cardano-sdk/projection';
import type { DataSource, QueryRunner } from 'typeorm';
import type { TypeormStabilityWindowBuffer, TypeormTipTracker } from '../../src/index.js';

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
  const entities = [BlockEntity, BlockDataEntity];
  let project$: Observable<Omit<ProjectionEvent, 'requestNext'>>;
  let buffer: TypeormStabilityWindowBuffer;
  let tipTracker: TypeormTipTracker;
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
        typeormTransactionCommit(),
        tipTracker.trackProjectedTip()
      )
    );

  beforeEach(async () => {
    dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
  });

  describe('error handling when combined with shareRetryBackoff', () => {
    let numChainSyncSubscriptions: number;

    beforeEach(async () => {
      ({ buffer, tipTracker } = createProjectorContext(entities));
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
          logger,
          projectedTip$: tipTracker.tip$
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
      ({ buffer, tipTracker } = createProjectorContext(entities));
      project$ = defer(() =>
        Bootstrap.fromCardanoNode({
          blocksBufferLength: 10,
          buffer,
          cardanoNode,
          logger,
          projectedTip$: tipTracker.tip$
        }).pipe(
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
      const [previousTip] = await lastValueFrom(project$.pipe(take(2), toArray()));
      // setting local tip to tip-1 creates an inconsistency: resumed projection will
      // try to insert a 'block' with an already existing 'height' which has a unique constraint.
      await firstValueFrom(tipTracker.trackProjectedTip()(of(previousTip)));
      // ADP-2807
      await expect(firstValueFrom(project$)).rejects.toThrowError(QueryFailedError);
    });
  });
});
