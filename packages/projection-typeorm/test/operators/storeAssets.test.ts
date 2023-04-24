import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  TypeormStabilityWindowBuffer,
  storeAssets,
  storeBlock,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../src';
import { Bootstrap, Mappers, requestNext } from '@cardano-sdk/projection';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { ChainSyncEventType } from '@cardano-sdk/core';
import { QueryRunner } from 'typeorm';
import { createProjectorTilFirst } from './util';
import { defer, from } from 'rxjs';
import { initializeDataSource } from '../util';

describe('storeAssets', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithMint);
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  const entities = [BlockEntity, BlockDataEntity, AssetEntity];

  const project$ = () =>
    Bootstrap.fromCardanoNode({
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger
    }).pipe(
      Mappers.withMint(),
      withTypeormTransaction({
        dataSource$: defer(() => from(initializeDataSource({ entities }))),
        logger
      }),
      storeBlock(),
      storeAssets(),
      buffer.storeBlockData(),
      typeormTransactionCommit(),
      requestNext()
    );

  const projectTilFirst = createProjectorTilFirst(project$);

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    buffer = new TypeormStabilityWindowBuffer({ allowNonSequentialBlockHeights: true, logger });
    await buffer.initialize(queryRunner);
  });

  afterEach(async () => {
    await queryRunner.release();
    buffer.shutdown();
  });

  it('inserts assets on mint, deletes when 1st mint block is rolled back', async () => {
    const repository = queryRunner.manager.getRepository(AssetEntity);
    const mintEvent = await projectTilFirst((evt) => evt.mint.length > 0);
    expect(await repository.count()).toBe(mintEvent.mint.length);
    const firstDbMint = await repository.findOne({ where: { id: mintEvent.mint[0].assetId } });
    expect(firstDbMint?.supply).toBe(mintEvent.mint[0].quantity);
    await projectTilFirst(
      (evt) =>
        evt.block.header.hash === mintEvent.block.header.hash && evt.eventType === ChainSyncEventType.RollBackward
    );
    expect(await repository.count()).toBe(0);
  });
});
