import {
  BlockDataEntity,
  BlockEntity,
  BossDb,
  STAKE_POOL_METADATA_QUEUE,
  TypeormStabilityWindowBuffer,
  storeBlock,
  storeStakePoolMetadataJob,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../src';
import { Bootstrap, Operators } from '@cardano-sdk/projection';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { ChainSyncEventType } from '@cardano-sdk/core';
import { QueryRunner } from 'typeorm';
import { StakePoolMetadataJob } from '../../src/pgBoss';
import { createProjectorTilFirst } from './util';
import { defer, filter, from } from 'rxjs';
import { initializeDataSource } from '../util';
import PgBoss from 'pg-boss';

const testPromise = () => {
  let resolvePromise: Function;
  const promise = new Promise<void>((resolve) => (resolvePromise = resolve));
  return [promise, resolvePromise!] as const;
};

describe('storeStakePoolMetadataJob', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithPoolRetirement);
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  const project$ = () =>
    Bootstrap.fromCardanoNode({
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger
    }).pipe(
      // skipping 1st event because it's not rolled back
      filter(({ block: { header }, requestNext }) => {
        const SKIP = 32_159;
        if (header.blockNo <= SKIP) {
          requestNext();
        }
        return header.blockNo > SKIP;
      }),
      Operators.withCertificates(),
      Operators.withStakePools(),
      withTypeormTransaction(
        {
          dataSource$: defer(() =>
            from(
              initializeDataSource({
                entities: [BlockEntity, BlockDataEntity],
                extensions: { pgBoss: true }
              })
            )
          ),
          logger
        },
        { pgBoss: true }
      ),
      storeBlock(),
      storeStakePoolMetadataJob(),
      buffer.storeBlockData(),
      typeormTransactionCommit(),
      Operators.requestNext()
    );
  const projectTilFirst = createProjectorTilFirst(project$);
  const projectTilFirstPoolUpdateWithMetadata = () =>
    projectTilFirst((evt) => evt.stakePools.updates.some((update) => update.poolParameters.metadataJson));

  beforeEach(async () => {
    const dataSource = await initializeDataSource({
      entities: [BlockEntity, BlockDataEntity],
      extensions: { pgBoss: true }
    });
    queryRunner = dataSource.createQueryRunner();
    buffer = new TypeormStabilityWindowBuffer({ allowNonSequentialBlockHeights: true, logger });
    await buffer.initialize(queryRunner);
  });

  afterEach(async () => {
    await queryRunner.release();
    buffer.shutdown();
  });

  it('creates jobs referencing Block table that can be picked up by a worker', async () => {
    const { block } = await projectTilFirstPoolUpdateWithMetadata();
    const jobQueryResult = await queryRunner.query(
      `SELECT * FROM pgboss.job WHERE block_height=${block.header.blockNo}`
    );
    expect(jobQueryResult).toHaveLength(1);
    const boss = new PgBoss({ db: new BossDb(queryRunner) });
    await boss.start();
    const [jobComplete, resolveJobComplete] = testPromise();
    void boss.work<StakePoolMetadataJob, boolean>(STAKE_POOL_METADATA_QUEUE, async ({ data }) => {
      expect(typeof data.metadataJson).toBe('object');
      resolveJobComplete();
      return true;
    });
    await jobComplete;
    await boss.stop();
  });

  it('rollbacks do not brick the worker', async () => {
    const { block } = await projectTilFirstPoolUpdateWithMetadata();
    const boss = new PgBoss({ db: new BossDb(queryRunner) });
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
