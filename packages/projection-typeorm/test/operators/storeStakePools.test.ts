import {
  BlockDataEntity,
  BlockEntity,
  CurrentPoolMetricsEntity,
  PoolMetadataEntity,
  PoolRegistrationEntity,
  PoolRetirementEntity,
  StakePoolEntity,
  createObservableConnection,
  storeBlock,
  storeStakePools,
  typeormTransactionCommit,
  willStoreStakePools,
  withTypeormTransaction
} from '../../src/index.js';
import { Bootstrap, Mappers, requestNext } from '@cardano-sdk/projection';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { connectionConfig$, initializeDataSource } from '../util.js';
import { createProjectorContext, createProjectorTilFirst } from './util.js';
import { lastValueFrom } from 'rxjs';
import type { DataSource, QueryRunner, Repository } from 'typeorm';
import type { ObservableCardanoNode } from '@cardano-sdk/core';
import type { TypeormStabilityWindowBuffer, TypeormTipTracker } from '../../src/index.js';

describe('storeStakePools', () => {
  const data = chainSyncData(ChainSyncDataSet.WithPoolRetirement);
  const entities = [
    BlockDataEntity,
    BlockEntity,
    CurrentPoolMetricsEntity,
    PoolRegistrationEntity,
    PoolRetirementEntity,
    StakePoolEntity,
    PoolMetadataEntity
  ];
  let poolsRepo: Repository<StakePoolEntity>;
  let dataSource: DataSource;
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  let tipTracker: TypeormTipTracker;

  const project = (cardanoNode: ObservableCardanoNode = data.cardanoNode) =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 10,
      buffer,
      cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(
      Mappers.withCertificates(),
      Mappers.withStakePools(),
      withTypeormTransaction({ connection$: createObservableConnection({ connectionConfig$, entities, logger }) }),
      storeBlock(),
      storeStakePools(),
      buffer.storeBlockData(),
      typeormTransactionCommit(),
      tipTracker.trackProjectedTip(),
      requestNext()
    );
  const projectTilFirst = createProjectorTilFirst(project);

  const loadStakePool = async (id: Cardano.PoolId) => {
    const stakePool = await poolsRepo.findOne({
      relations: {
        lastRegistration: { block: true },
        lastRetirement: { block: true },
        registrations: true,
        retirements: true
      },
      where: { id }
    });
    return stakePool!;
  };

  beforeEach(async () => {
    dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    poolsRepo = queryRunner.manager.getRepository(StakePoolEntity);
    ({ buffer, tipTracker } = createProjectorContext(entities));
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
  });

  describe('regression', () => {
    it('activates a previously retired pool with several registrations', async () => {
      await lastValueFrom(project(chainSyncData(ChainSyncDataSet.PreviewStakePoolProblem).cardanoNode));
      const pool = await poolsRepo.findOne({
        where: { id: Cardano.PoolId('pool1nk3uj4fdd6d42tx26y537xaejd76u6xyrn0ql8sr4r9tullk84y') }
      });
      expect(pool?.status).toBe(Cardano.StakePoolStatus.Active);
    });
  });

  it('typeorm loads correctly typed properties', async () => {
    const projectionEvent = await projectTilFirst((evt) => evt.stakePools.retirements.length > 0);
    const stakePool = await loadStakePool(projectionEvent.stakePools.retirements[0].poolId);
    // StakePoolEntity props
    expect(typeof stakePool.id).toBe('string');
    expect(typeof stakePool.status).toBe('string');
    // PoolRegistrationEntity props
    expect(typeof stakePool.lastRegistration!.id).toBe('bigint');
    expect(typeof stakePool.lastRegistration!.cost).toBe('bigint');
    expect(typeof stakePool.lastRegistration!.margin?.denominator).toBe('number');
    expect(typeof stakePool.lastRegistration!.marginPercent).toBe('number');
    if (stakePool.lastRegistration!.metadataHash !== null) {
      expect(typeof stakePool.lastRegistration!.metadataHash).toBe('string');
      expect(typeof stakePool.lastRegistration!.metadataUrl).toBe('string');
    }
    expect(typeof stakePool.lastRegistration!.owners![0]).toBe('string');
    expect(typeof stakePool.lastRegistration!.pledge).toBe('bigint');
    expect(typeof stakePool.lastRegistration!.relays![0].__typename).toBe('string');
    expect(typeof stakePool.lastRegistration!.rewardAccount).toBe('string');
    expect(typeof stakePool.lastRegistration!.vrf).toBe('string');
    expect(typeof stakePool.lastRegistration!.block?.height).toBe('number');
    // PoolRetirementEntity props
    expect(typeof stakePool.lastRetirement!.id).toBe('bigint');
    expect(typeof stakePool.lastRetirement!.retireAtEpoch).toBe('number');
    expect(typeof stakePool.lastRetirement!.block?.height).toBe('number');
  });

  describe('pool status transitions', () => {
    test.todo('retired->activating');

    // Rollback crosses epoch boundary
    test.todo('active->activating');
    test.todo('retired->retiring');

    test('activating->active', async () => {
      const poolId = Cardano.PoolId('pool1ml3j87d8n3u8czhej8pxfmnpmdt7jgqyv7kraqdvnx9lztt6xrt');
      // Block 33288
      const { epochNo: firstRegistrationEpoch } = await projectTilFirst((evt) =>
        evt.stakePools.updates.some((update) => update.poolParameters.id === poolId)
      );
      const activatingStakePool = await loadStakePool(poolId);
      expect(activatingStakePool.status).toBe(Cardano.StakePoolStatus.Activating);

      await projectTilFirst((evt) => evt.epochNo === firstRegistrationEpoch + 2);
      const activeStakePool = await loadStakePool(poolId);
      expect(activeStakePool.status).toBe(Cardano.StakePoolStatus.Active);
    });

    test('activating->retiring->activating->retiring->retired', async () => {
      const poolId = Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q');
      // Block 33267
      await projectTilFirst((evt) => evt.stakePools.updates.some((update) => update.poolParameters.id === poolId));
      const activatingStakePool = await loadStakePool(poolId);
      expect(activatingStakePool.status).toBe(Cardano.StakePoolStatus.Activating);

      // Block 33277
      const firstRetiringEvent = await projectTilFirst((evt) =>
        evt.stakePools.retirements.some((retirement) => retirement.poolId === poolId)
      );
      const retiringStakePool = await loadStakePool(poolId);
      expect(retiringStakePool.status).toBe(Cardano.StakePoolStatus.Retiring);

      // Block 33278
      const secondRetiringEvent = await projectTilFirst((evt) =>
        evt.stakePools.retirements.some((retirement) => retirement.poolId === poolId)
      );

      // Rollback second retire certificate
      await projectTilFirst(
        (evt) =>
          evt.eventType === ChainSyncEventType.RollBackward &&
          evt.block.header.blockNo === secondRetiringEvent.block.header.blockNo
      );
      const stillRetiringStakePool = await loadStakePool(poolId);
      // Still retiring, because 1st retiring event is still in effect
      expect(stillRetiringStakePool.status).toBe(Cardano.StakePoolStatus.Retiring);

      // Rollback first retire certificate
      await projectTilFirst(
        (evt) =>
          evt.eventType === ChainSyncEventType.RollBackward &&
          evt.block.header.blockNo === firstRetiringEvent.block.header.blockNo
      );
      const reactivatingStakePool = await loadStakePool(poolId);
      // Both retirement certificates were rolled back
      expect(reactivatingStakePool.status).toBe(Cardano.StakePoolStatus.Activating);

      // Replayed first and second retiring event
      await projectTilFirst((evt) => evt.block.header.blockNo === secondRetiringEvent.block.header.blockNo);
      const reretiringStakePool = await loadStakePool(poolId);
      expect(reretiringStakePool.status).toBe(Cardano.StakePoolStatus.Retiring);

      const waitForEpoch = secondRetiringEvent.stakePools.retirements.find(
        (retirement) => retirement.poolId === poolId
      )!.epoch;
      await projectTilFirst((evt) => evt.epochNo === waitForEpoch);
      const retiredStakePool = await loadStakePool(poolId);
      expect(retiredStakePool.status).toBe(Cardano.StakePoolStatus.Retired);
    });

    it('lastRetirement is always set to an entity representing the latest certificate', async () => {
      const poolId = Cardano.PoolId('pool12pq2rzx8d7ern46udp6xrn0e0jaqt9hes9gs85hstp0egvfnf9q');
      await projectTilFirst((evt) => evt.stakePools.retirements.some((retirement) => retirement.poolId === poolId));
      const { lastRetirement: initialRetirement } = await loadStakePool(poolId);
      expect(initialRetirement).toBeTruthy();

      await projectTilFirst((evt) => evt.stakePools.retirements.some((retirement) => retirement.poolId === poolId));
      const { lastRetirement: updatedRetirement } = await loadStakePool(poolId);
      expect(updatedRetirement!.id).not.toEqual(initialRetirement!.id);

      // Rollback second retire certificate
      await projectTilFirst(
        (evt) =>
          evt.eventType === ChainSyncEventType.RollBackward &&
          evt.stakePools.retirements.some((retirement) => retirement.poolId === poolId)
      );
      const { lastRetirement: rolledBackRetirement } = await loadStakePool(poolId);
      expect(rolledBackRetirement!.id).toEqual(initialRetirement!.id);
    });

    it.todo('lastRegistration is always set to an entity representing the latest certificate');
  });
});

describe('willStoreStakePools', () => {
  it('returns true if there are both updates and retirements', () => {
    expect(
      willStoreStakePools({
        stakePools: { retirements: [{} as never], updates: [{} as never] }
      })
    ).toBeTruthy();
  });

  it('returns true if there are updates', () => {
    expect(
      willStoreStakePools({
        stakePools: { retirements: [], updates: [{} as never] }
      })
    ).toBeTruthy();
  });

  it('returns true if there are retirements', () => {
    expect(
      willStoreStakePools({
        stakePools: { retirements: [{} as never], updates: [] }
      })
    ).toBeTruthy();
  });

  it('returns false if there are no updates or retirements', () => {
    expect(
      willStoreStakePools({
        stakePools: { retirements: [], updates: [] }
      })
    ).toBeFalsy();
  });
});
