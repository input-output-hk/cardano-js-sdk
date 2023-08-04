import {
  BlockDataEntity,
  BlockEntity,
  StakeKeyRegistrationEntity,
  TypeormStabilityWindowBuffer,
  certificatePointerToId,
  storeBlock,
  storeStakeKeyRegistrations,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../src';
import { Bootstrap, Mappers, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { DataSource, QueryRunner, Repository } from 'typeorm';
import { Observable, firstValueFrom, of, pairwise, takeWhile } from 'rxjs';
import { createProjectorTilFirst, createRollBackwardEventFor, createStubProjectionSource } from './util';
import { initializeDataSource } from '../util';

describe('storeStakeKeyRegistrations', () => {
  const data = chainSyncData(ChainSyncDataSet.WithPoolRetirement);
  let stakeKeyRegistrationsRepo: Repository<StakeKeyRegistrationEntity>;
  let dataSource: DataSource;
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;

  const applyOperators = (evt$: Observable<ProjectionEvent<{}>>) =>
    evt$.pipe(
      Mappers.withCertificates(),
      Mappers.withStakeKeyRegistrations(),
      withTypeormTransaction({ dataSource$: of(dataSource), logger }),
      storeBlock(),
      storeStakeKeyRegistrations(),
      buffer.storeBlockData(),
      typeormTransactionCommit(),
      requestNext()
    );

  const project = () =>
    Bootstrap.fromCardanoNode({
      buffer,
      cardanoNode: data.cardanoNode,
      logger
    }).pipe(applyOperators);
  const projectTilFirst = createProjectorTilFirst(project);

  beforeEach(async () => {
    dataSource = await initializeDataSource({
      entities: [BlockDataEntity, BlockEntity, StakeKeyRegistrationEntity]
    });
    queryRunner = dataSource.createQueryRunner();
    stakeKeyRegistrationsRepo = queryRunner.manager.getRepository(StakeKeyRegistrationEntity);
    buffer = new TypeormStabilityWindowBuffer({ allowNonSequentialBlockHeights: true, logger });
    await buffer.initialize(queryRunner);
  });

  afterEach(async () => {
    await queryRunner.release();
    await dataSource.destroy();
    buffer.shutdown();
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
