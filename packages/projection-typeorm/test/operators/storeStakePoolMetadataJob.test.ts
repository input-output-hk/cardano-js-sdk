import {
  BlockDataEntity,
  BlockEntity,
  STAKE_POOL_METADATA_QUEUE,
  TypeormStabilityWindowBuffer,
  TypeormTipTracker,
  createObservableConnection,
  createStoreStakePoolMetadataJob,
  storeBlock,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../src';
import { Bootstrap, Mappers, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { ChainSyncEventType } from '@cardano-sdk/core';
import { Observable, filter, of } from 'rxjs';
import { QueryRunner } from 'typeorm';
import { StakePoolMetadataJob, createPgBoss } from '../../src/pgBoss';
import { connectionConfig, initializeDataSource } from '../util';
import { createProjectorContext, createProjectorTilFirst } from './util';

const testPromise = () => {
  let resolvePromise: Function;
  const promise = new Promise<void>((resolve) => (resolvePromise = resolve));
  return [promise, resolvePromise!] as const;
};

describe('storeStakePoolMetadataJob', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithPoolRetirement);
  const entities = [BlockEntity, BlockDataEntity];
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  let tipTracker: TypeormTipTracker;

  const storeData = <T extends Mappers.WithStakePools>(evt$: Observable<ProjectionEvent<T>>) =>
    evt$.pipe(
      withTypeormTransaction({
        connection$: createObservableConnection({
          connectionConfig$: of(connectionConfig),
          entities: [BlockEntity, BlockDataEntity],
          extensions: { pgBoss: true },
          logger
        }),
        pgBoss: true
      }),
      storeBlock(),
      createStoreStakePoolMetadataJob()(),
      buffer.storeBlockData(),
      typeormTransactionCommit()
    );

  const project$ = () =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 10,
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(
      // skipping 1st event because it's not rolled back
      filter((evt) => {
        const SKIP = 32_159;
        if (evt.block.header.blockNo <= SKIP) {
          evt.requestNext();
        }
        return evt.block.header.blockNo > SKIP;
      }),
      Mappers.withCertificates(),
      Mappers.withStakePools(),
      storeData,
      tipTracker.trackProjectedTip(),
      requestNext()
    );
  const projectTilFirst = createProjectorTilFirst(project$);
  const projectTilFirstPoolUpdateWithMetadata = () =>
    projectTilFirst((evt) => evt.stakePools.updates.some((update) => update.poolParameters.metadataJson));

  beforeEach(async () => {
    const dataSource = await initializeDataSource({
      entities,
      extensions: { pgBoss: true }
    });
    queryRunner = dataSource.createQueryRunner();
    ({ buffer, tipTracker } = createProjectorContext(entities));
  });

  afterEach(async () => {
    await queryRunner.release();
  });

  it('creates jobs referencing Block table that can be picked up by a worker', async () => {
    const { block } = await projectTilFirstPoolUpdateWithMetadata();
    const jobQueryResult = await queryRunner.query(`SELECT * FROM pgboss.job WHERE block_slot=${block.header.slot}`);
    expect(jobQueryResult).toHaveLength(1);
    const boss = createPgBoss(queryRunner, logger);
    await boss.start();
    const [jobComplete, resolveJobComplete] = testPromise();
    void boss.work<StakePoolMetadataJob, boolean>(
      STAKE_POOL_METADATA_QUEUE,
      { newJobCheckInterval: 100 },
      async ({ data }) => {
        expect(typeof data.metadataJson).toBe('object');
        resolveJobComplete();
        return true;
      }
    );
    await jobComplete;
    await boss.stop();
  });

  it('rollbacks do not brick the worker', async () => {
    const { block } = await projectTilFirstPoolUpdateWithMetadata();
    const boss = createPgBoss(queryRunner, logger);
    await boss.start();
    const [rollbackComplete, resolveRollbackComplete] = testPromise();
    const [job1Complete, resolveJob1Complete] = testPromise();
    const [job2Complete, resolveJob2Complete] = testPromise();
    void boss.work<StakePoolMetadataJob, boolean>(
      STAKE_POOL_METADATA_QUEUE,
      jest
        .fn()
        .mockImplementationOnce(async () => {
          await rollbackComplete;
          resolveJob1Complete();
          return Promise.reject<boolean>('Failed to write metadata because poolRegistration no longer exists');
        })
        .mockImplementationOnce(async () => {
          resolveJob2Complete();
          return true;
        })
    );
    const { block: rollbackBlock } = await projectTilFirst(
      (evt) => evt.eventType === ChainSyncEventType.RollBackward && evt.block.header.blockNo === block.header.blockNo
    );
    // sanity check
    expect(rollbackBlock.header.hash).toEqual(block.header.hash);
    resolveRollbackComplete();
    await job1Complete;
    await projectTilFirstPoolUpdateWithMetadata();
    await job2Complete;
    await boss.stop();
  });
});
