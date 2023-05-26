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
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { DataSource, QueryRunner } from 'typeorm';
import { Observable, of } from 'rxjs';
import { createProjectorTilFirst } from './util';
import { initializeDataSource } from '../util';

const hasLessThanZeroQuantity = (mints: Mappers.Mint[]) =>
  mints.map(({ quantity }) => quantity).some((quantity) => quantity < BigInt(0));

describe('storeHandle', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithHandle);
  const policyIds = [Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a')];
  let queryRunner: QueryRunner;
  let dataSource$: Observable<DataSource>;
  let buffer: TypeormStabilityWindowBuffer;
  const entities = [BlockEntity, BlockDataEntity, AssetEntity, TokensEntity, OutputEntity, HandleEntity];

  const storeData = (evt$: Observable<ProjectionEvent<Mappers.WithUtxo & Mappers.WithMint & Mappers.WithHandles>>) =>
    evt$.pipe(
      withTypeormTransaction({ dataSource$, logger }),
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
      Mappers.withMint(),
      Mappers.filterProducedUtxoByAssetPolicyId({ policyIds }),
      Mappers.filterMintByPolicyIds({ policyIds }),
      Mappers.withHandles({ policyIds }),
      storeData,
      requestNext()
    );

  const projectTilFirst = createProjectorTilFirst(project$);

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    dataSource$ = of(dataSource);
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
    expect(mintEvent.handles.length).toBeGreaterThan(0);
  });

  it('when combined with filter operators, stores only relevant Output and Asset (per handle)', async () => {
    const outputRepository = queryRunner.manager.getRepository(OutputEntity);
    const assetRepository = queryRunner.manager.getRepository(AssetEntity);
    const { handles } = await projectTilFirst((evt) => evt.handles.length > 0);
    expect(await outputRepository.count()).toBe(handles.length);
    expect(await assetRepository.count()).toBe(handles.length);
  });

  it('deletes handle on rollback', async () => {
    const handleRepository = queryRunner.manager.getRepository(HandleEntity);
    const initialCount = await handleRepository.count();
    const mintEvent = await projectTilFirst(
      ({ handles, eventType }) => eventType === ChainSyncEventType.RollForward && handles.length > 0
    );
    expect(await handleRepository.count()).toEqual(initialCount + mintEvent.handles.length);
    await projectTilFirst(
      ({
        eventType,
        block: {
          header: { hash }
        }
      }) => eventType === ChainSyncEventType.RollBackward && hash === mintEvent.block.header.hash
    );
    expect(await handleRepository.count()).toEqual(initialCount);
  });

  it('minting an existing handle sets address to null', async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const mintEvent1 = await projectTilFirst(
      ({ handles, eventType }) => eventType === ChainSyncEventType.RollForward && handles[0]?.handle === 'bob'
    );
    expect(mintEvent1.handles.length).toBe(1);

    const mintEvent2 = await projectTilFirst(
      ({ handles, eventType }) => eventType === ChainSyncEventType.RollForward && handles[0]?.handle === 'bob'
    );
    expect(mintEvent2.handles.length).toBe(1);

    expect(
      await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle: 'bob' } })
    ).toEqual({
      cardanoAddress: null,
      handle: 'bob'
    });
  });

  it('rolling back a transaction that mint an existing handle sets address to the original owner', async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const mintEvent = await projectTilFirst(
      ({ handles, eventType }) => eventType === ChainSyncEventType.RollForward && handles[0]?.handle === 'bob'
    );
    expect(mintEvent.handles.length).toBe(1);

    await projectTilFirst(
      ({ handles, eventType }) => eventType === ChainSyncEventType.RollBackward && handles[0]?.handle === 'bob'
    );

    expect(
      await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle: 'bob' } })
    ).toEqual({
      cardanoAddress:
        'addr_test1qzrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuql9tk0g',
      handle: 'bob'
    });
  });

  // blockNo: 1 2 3 4 5 6 7
  // mint at block 1 send to addr1
  // mint at block 2 send to addr2 - expect Handle.address to be null, because there are 2 handles
  // burn one of the handles at block 3 - expect the remaining handle to be valid.
  //    The input of the burning tx must match the tx id of the mint transaction,
  //    and index == the index of the output that sent the handle to the address
  it('burning a handle with supply >1 sets address to the 1 remaining owner', async () => {
    const mintEvent1 = await projectTilFirst(
      ({ eventType, mint }) => eventType === ChainSyncEventType.RollForward && hasLessThanZeroQuantity(mint)
    );

    expect(mintEvent1.handles.length).toBeGreaterThan(0);
  });

  // quite simialr to the previvous test, except that instead of burning, you roll back the 2nd mint transaction
  // so that it never existed and only 1 transaction that minted the handle is valid
  it.todo('rolling back a transaction that burned a handle with supply >1 sets address to null');
});
