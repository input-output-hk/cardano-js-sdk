import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { DataSource, QueryRunner, Repository } from 'typeorm';
import { PoolRegistrationEntity, PoolRetirementEntity, StakePoolEntity, createSinksFactory } from '../../src';
import { Projections, ProjectionsEvent, projectIntoSink } from '@cardano-sdk/projection';
import { initializeDataSource } from '../connection';
import { lastValueFrom, of, takeWhile } from 'rxjs';
import pick from 'lodash/pick';

describe('sinks/stakePools', () => {
  const projections = pick(Projections.allProjections, 'stakePools');
  const data = chainSyncData(ChainSyncDataSet.WithPoolRetirement);
  let poolsRepo: Repository<StakePoolEntity>;
  let registrationsRepo: Repository<PoolRegistrationEntity>;
  let retirementsRepo: Repository<PoolRetirementEntity>;
  let dataSource: DataSource;
  let queryRunner: QueryRunner;

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
    dataSource = await initializeDataSource(projections);
    queryRunner = dataSource.createQueryRunner();
    poolsRepo = queryRunner.manager.getRepository(StakePoolEntity);
    registrationsRepo = queryRunner.manager.getRepository(PoolRegistrationEntity);
    retirementsRepo = queryRunner.manager.getRepository(PoolRetirementEntity);
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    registrationsRepo;
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    retirementsRepo;
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
  });

  const project$ = () =>
    projectIntoSink({
      cardanoNode: data.cardanoNode,
      logger,
      projections,
      sinksFactory: createSinksFactory({
        allowNonSequentialBlockHeights: true,
        dataSource$: of(dataSource),
        logger
      })
    });

  const projectTilFirst = async (filter: (evt: ProjectionsEvent<typeof projections>) => boolean) =>
    lastValueFrom(project$().pipe(takeWhile((evt) => !filter(evt), true)));

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
