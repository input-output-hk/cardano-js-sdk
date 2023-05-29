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
import { BaseProjectionEvent, Bootstrap, Mappers, ProjectionEvent, requestNext } from '@cardano-sdk/projection';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { Observable, defer, firstValueFrom, from } from 'rxjs';
import { QueryRunner } from 'typeorm';
import { createProjectorTilFirst, createStubProjectionSource } from './util';
import { initializeDataSource } from '../util';

describe('storeHandle', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithHandle);
  const policyIds = [Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a')];
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  const entities = [BlockEntity, BlockDataEntity, AssetEntity, TokensEntity, OutputEntity, HandleEntity];

  const dataSource$ = defer(() =>
    from(initializeDataSource({ devOptions: { dropSchema: false, synchronize: false }, entities }))
  );

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

  // eslint-disable-next-line unicorn/consistent-function-scoping
  const applyOperators = () => (evt$: Observable<ProjectionEvent<{}>>) =>
    evt$.pipe(
      Mappers.withUtxo(),
      Mappers.withMint(),
      Mappers.filterProducedUtxoByAssetPolicyId({ policyIds }),
      Mappers.filterMintByPolicyIds({ policyIds }),
      Mappers.withHandles({ policyIds }),
      storeData,
      requestNext()
    );

  const project$ = () =>
    Bootstrap.fromCardanoNode({
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger
    }).pipe(applyOperators());

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

  it('burning a handle with supply >1 sets address to the 1 remaining owner', async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const mintEvent1 = await projectTilFirst(
      ({ eventType, mint }) => eventType === ChainSyncEventType.RollForward && mint[0]?.quantity === -1n
    );
    expect(mintEvent1.handles.length).toBe(0);

    expect(
      await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle: 'bob' } })
    ).toEqual({
      cardanoAddress:
        'addr_test1qzrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuql9tk0g',
      handle: 'bob'
    });
  });

  it('rolling back a transaction that burned a handle with supply >1 sets address to null', async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const mintEvent1 = await projectTilFirst(
      ({ eventType, mint }) => eventType === ChainSyncEventType.RollBackward && mint[0]?.quantity === -1n
    );
    expect(mintEvent1.handles.length).toBe(0);
    expect(
      await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle: 'bob' } })
    ).toEqual({
      cardanoAddress: null,
      handle: 'bob'
    });
  });

  it('transferring handle updates the address to the new owner, rolling back sets it to original owner', async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const mintEvt = await projectTilFirst((evt) => evt.handles.length > 0);
    const newOwnerAddress = Cardano.PaymentAddress(
      'addr_test1qpfhhfy2qgls50r9u4yh0l7z67xpg0a5rrhkmvzcuqrd0znuzcjqw982pcftgx53fu5527z2cj2tkx2h8ux2vxsg475q9gw0lz'
    );
    const originalOwnerAddress = mintEvt.handles[0].address;
    expect(originalOwnerAddress).not.toEqual(newOwnerAddress);
    const header = {
      blockNo: Cardano.BlockNo(mintEvt.block.header.blockNo + 1),
      hash: Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000'),
      slot: Cardano.Slot(mintEvt.block.header.slot + 1)
    };
    const transferSourceEvt: BaseProjectionEvent = {
      block: {
        body: [
          {
            body: {
              fee: 123n,
              inputs: [],
              outputs: [
                {
                  address: newOwnerAddress,
                  value: {
                    assets: new Map([[mintEvt.handles[0].assetId, 1n]]),
                    coins: 123n
                  }
                }
              ]
            },
            id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000'),
            inputSource: Cardano.InputSource.inputs,
            witness: {
              signatures: new Map()
            }
          }
        ],
        header,
        totalOutput: 123n,
        txCount: 1
      },
      crossEpochBoundary: false,
      epochNo: mintEvt.epochNo,
      eraSummaries: mintEvt.eraSummaries,
      eventType: ChainSyncEventType.RollForward,
      genesisParameters: mintEvt.genesisParameters,
      tip: header
    };
    const transferEvt = await firstValueFrom(createStubProjectionSource([transferSourceEvt]).pipe(applyOperators()));
    expect(transferEvt.handles[0].handle).toEqual(mintEvt.handles[0].handle);
    expect(transferEvt.handles[0].address).toEqual(newOwnerAddress);
    const handleInDbAfterTransfer = await repository.findOneBy({ handle: transferEvt.handles[0].handle });
    expect(handleInDbAfterTransfer?.cardanoAddress).toEqual(newOwnerAddress);

    const rollbackSourceEvt: BaseProjectionEvent = {
      ...mintEvt,
      eventType: ChainSyncEventType.RollBackward,
      point: mintEvt.block.header
    };
    await firstValueFrom(createStubProjectionSource([rollbackSourceEvt]).pipe(applyOperators()));
    const handleInDbAfterTransferRollback = await repository.findOneBy({ handle: transferEvt.handles[0].handle });
    expect(handleInDbAfterTransferRollback?.cardanoAddress).toEqual(originalOwnerAddress);
  });
});
