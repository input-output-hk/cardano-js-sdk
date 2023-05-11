import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  HandleEntity,
  OutputEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  storeAssets,
  storeBlock,
  storeHandles,
  storeUtxo,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../src';
import { Bootstrap, Mappers, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { Observable, defer, from } from 'rxjs';
import { QueryRunner } from 'typeorm';
import { createProjectorTilFirst } from './util';
import { initializeDataSource } from '../util';

describe('storeHandle', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithHandle);
  const policyIds = [Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a')];
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  const entities = [BlockEntity, BlockDataEntity, AssetEntity, TokensEntity, OutputEntity, HandleEntity];

  const storeData = (evt$: Observable<ProjectionEvent<Mappers.WithUtxo & Mappers.WithMint & Mappers.WithHandles>>) =>
    evt$.pipe(
      withTypeormTransaction({
        dataSource$: defer(() => from(initializeDataSource({ entities }))),
        logger
      }),
      storeBlock(),
      storeAssets(),
      storeUtxo(),
      storeHandles(),
      buffer.storeBlockData(),
      typeormTransactionCommit()
    );

  const project$ = () =>
    Bootstrap.fromCardanoNode({
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger
    }).pipe(
      Mappers.withUtxo(),
      Mappers.filterProducedUtxoByAssetPolicyId({ policyIds }),
      Mappers.withMint(),
      Mappers.withHandles({ policyIds }),
      storeData,
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

  it('inserts handle on mint', async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const mintEvent = await projectTilFirst((evt) => evt.handles.length > 0);
    expect(await repository.count()).toBe(mintEvent.handles.length);
  });
  it.todo('deletes handle on rollback');

  it.todo('minting an existing handle sets address to null');
  it.todo('rolling back a transaction that mint an existing handle sets address to the original owner');

  it.todo('burning an handle with supply >1 sets address to the 1 remaining owner');
  it.todo('rolling back a transaction that burned a handle with supply >1 sets address to null');
});
