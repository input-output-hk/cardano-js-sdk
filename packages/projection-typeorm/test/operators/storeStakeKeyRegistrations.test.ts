import {
  BlockDataEntity,
  BlockEntity,
  StakeKeyRegistrationEntity,
  certificatePointerToId,
  createObservableConnection,
  storeBlock,
  storeStakeKeyRegistrations,
  typeormTransactionCommit,
  willStoreStakeKeyRegistrations,
  withTypeormTransaction
} from '../../src/index.js';
import { Bootstrap, Mappers, requestNext } from '@cardano-sdk/projection';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { connectionConfig$, initializeDataSource } from '../util.js';
import {
  createProjectorContext,
  createProjectorTilFirst,
  createRollBackwardEventFor,
  createStubProjectionSource
} from './util.js';
import { firstValueFrom, pairwise, takeWhile } from 'rxjs';
import type { DataSource, QueryRunner, Repository } from 'typeorm';
import type { Observable } from 'rxjs';
import type { ProjectionEvent } from '@cardano-sdk/projection';
import type { StakeKeyRegistration } from '@cardano-sdk/projection/dist/cjs/operators/Mappers';
import type { TypeormStabilityWindowBuffer, TypeormTipTracker } from '../../src/index.js';

describe('storeStakeKeyRegistrations', () => {
  const data = chainSyncData(ChainSyncDataSet.WithPoolRetirement);
  const entities = [BlockDataEntity, BlockEntity, StakeKeyRegistrationEntity];
  let stakeKeyRegistrationsRepo: Repository<StakeKeyRegistrationEntity>;
  let dataSource: DataSource;
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  let tipTracker: TypeormTipTracker;

  const applyOperators = (evt$: Observable<ProjectionEvent<{}>>) =>
    evt$.pipe(
      Mappers.withCertificates(),
      Mappers.withStakeKeyRegistrations(),
      withTypeormTransaction({ connection$: createObservableConnection({ connectionConfig$, entities, logger }) }),
      storeBlock(),
      storeStakeKeyRegistrations(),
      buffer.storeBlockData(),
      typeormTransactionCommit(),
      tipTracker.trackProjectedTip(),
      requestNext()
    );

  const project = () =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 1,
      buffer,
      cardanoNode: data.cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(applyOperators);
  const projectTilFirst = createProjectorTilFirst(project);

  beforeEach(async () => {
    dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    stakeKeyRegistrationsRepo = queryRunner.manager.getRepository(StakeKeyRegistrationEntity);
    ({ buffer, tipTracker } = createProjectorContext(entities));
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
  });

  it('inserts and deletes stake key registrations', async () => {
    const [prevEvent, rollForwardEvent] = await firstValueFrom(
      project().pipe(
        pairwise(),
        takeWhile(([_, evt]) => evt.stakeKeyRegistrations.length === 0)
      )
    );
    expect(await stakeKeyRegistrationsRepo.count()).toBe(rollForwardEvent.stakeKeyRegistrations.length);
    await firstValueFrom(
      createStubProjectionSource([createRollBackwardEventFor(rollForwardEvent, prevEvent.block.header)]).pipe(
        applyOperators
      )
    );
    expect(await stakeKeyRegistrationsRepo.count()).toBe(0);
  });

  it('is queryable by certificate pointer', async () => {
    const { stakeKeyRegistrations } = await projectTilFirst((evt) => evt.stakeKeyRegistrations.length > 0);
    const registration = await stakeKeyRegistrationsRepo.findOne({
      where: {
        id: certificatePointerToId(stakeKeyRegistrations[0].pointer)
      }
    });
    expect(registration?.stakeKeyHash).toEqual(stakeKeyRegistrations[0].stakeKeyHash);
  });
});

describe('willStoreStakeKeyRegistrations', () => {
  it('returns true if stakeKeyRegistrations are bigger than 1', () => {
    expect(
      willStoreStakeKeyRegistrations({
        stakeKeyRegistrations: [{} as StakeKeyRegistration]
      })
    ).toBeTruthy();
  });

  it('returns false if there are no stakeKeyRegistrations', () => {
    expect(
      willStoreStakeKeyRegistrations({
        stakeKeyRegistrations: []
      })
    ).toBeFalsy();
  });
});
