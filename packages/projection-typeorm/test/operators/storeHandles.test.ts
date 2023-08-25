import { Asset, Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  HandleEntity,
  NftMetadataEntity,
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
import { ChainSyncDataSet, chainSyncData, logger, mockProviders } from '@cardano-sdk/util-dev';
import { Observable, defer, firstValueFrom, from } from 'rxjs';
import { QueryRunner } from 'typeorm';
import { createProjectorTilFirst, createStubProjectionSource } from './util';
import { initializeDataSource } from '../util';

describe('storeHandles', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithHandle);
  const policyId = Cardano.PolicyId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a');
  const policyIds = [policyId];
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  const entities = [
    BlockEntity,
    BlockDataEntity,
    AssetEntity,
    NftMetadataEntity,
    TokensEntity,
    OutputEntity,
    HandleEntity
  ];

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
      Mappers.withCIP67(),
      Mappers.withHandles({ policyIds }),
      storeData,
      requestNext()
    );

  const project$ = () =>
    Bootstrap.fromCardanoNode({ blocksBufferLength: 10, buffer, cardanoNode: stubEvents.cardanoNode, logger }).pipe(
      applyOperators()
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

  it(`minting an existing handle sets address to null,
      rolling back a transaction that mint an existing handle sets address to the original owner`, async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const firstMintEvent = await projectTilFirst(
      ({ handles, eventType }) => eventType === ChainSyncEventType.RollForward && handles[0]?.handle === 'bob'
    );
    const firstAddress = firstMintEvent.handles[0].latestOwnerAddress;
    expect(firstMintEvent.handles.length).toBe(1);
    const secondMintEvent = await projectTilFirst(
      ({ handles, eventType, mintedAssetTotalSupplies }) =>
        eventType === ChainSyncEventType.RollForward &&
        handles[0]?.handle === 'bob' &&
        mintedAssetTotalSupplies[firstMintEvent.handles[0].assetId] === 2n
    );
    expect(
      await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle: 'bob' } })
    ).toEqual({
      cardanoAddress: null,
      handle: 'bob'
    });
    expect(secondMintEvent.handles.length).toBe(1);
    expect(secondMintEvent.handles[0].latestOwnerAddress).not.toEqual(firstAddress);

    await projectTilFirst(
      ({ block: { header }, eventType }) =>
        eventType === ChainSyncEventType.RollBackward && header.hash === secondMintEvent.block.header.hash
    );

    expect(
      await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle: 'bob' } })
    ).toEqual({
      cardanoAddress: firstAddress,
      handle: 'bob'
    });
  });

  it('burning a handle with supply >1 sets address and datum to the 1 remaining owner', async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const burnEvent = await projectTilFirst(
      ({ eventType, mint }) => eventType === ChainSyncEventType.RollForward && mint[0]?.quantity === -1n
    );
    expect(burnEvent.handles.length).toBe(1);
    expect(
      await repository.findOne({
        select: { cardanoAddress: true, handle: true, hasDatum: true },
        where: { handle: 'bob' }
      })
    ).toEqual({
      cardanoAddress:
        'addr_test1qzrljm7nskakjydxlr450ktsj08zuw6aktvgfkmmyw9semrkrezryq3ydtmkg0e7e2jvzg443h0ffzfwd09wpcxy2fuql9tk0g',
      handle: 'bob',
      hasDatum: true
    });
  });

  it('rolling back a transaction that burned a handle with supply >1 sets address to null', async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const mintEvent1 = await projectTilFirst(
      ({ eventType, mint }) => eventType === ChainSyncEventType.RollBackward && mint[0]?.quantity === -1n
    );
    expect(mintEvent1.handles.length).toBe(1);
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
    const originalOwnerAddress = mintEvt.handles[0].latestOwnerAddress;
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
    expect(transferEvt.handles[0].latestOwnerAddress).toEqual(newOwnerAddress);
    const handleInDbAfterTransfer = await repository.findOneBy({ handle: transferEvt.handles[0].handle });
    expect(handleInDbAfterTransfer?.cardanoAddress).toEqual(newOwnerAddress);

    const rollbackSourceEvt: BaseProjectionEvent = {
      ...transferEvt,
      eventType: ChainSyncEventType.RollBackward,
      point: mintEvt.block.header
    };
    await firstValueFrom(createStubProjectionSource([rollbackSourceEvt]).pipe(applyOperators()));
    const handleInDbAfterTransferRollback = await repository.findOneBy({ handle: transferEvt.handles[0].handle });
    expect(handleInDbAfterTransferRollback?.cardanoAddress).toEqual(originalOwnerAddress);
  });

  describe('multiple transactions in 1 block', () => {
    const blockHeader = {
      blockNo: Cardano.BlockNo(317_881),
      hash: Cardano.BlockId('0000000000000000000000000000000000000000000000000000000000000000'),
      slot: Cardano.Slot(13_633_737)
    };
    const createMultiTxProjectionSource = (txs: Pick<Cardano.OnChainTx, 'id' | 'body'>[]) =>
      createStubProjectionSource([
        {
          block: {
            body: txs.map((tx) => ({
              ...tx,
              inputSource: Cardano.InputSource.inputs,
              witness: { signatures: new Map() }
            })),
            header: blockHeader,
            totalOutput: 123n,
            txCount: txs.length
          },
          crossEpochBoundary: false,
          epochNo: Cardano.EpochNo(31),
          eraSummaries: [],
          eventType: ChainSyncEventType.RollForward,
          genesisParameters: mockProviders.genesisParameters,
          tip: blockHeader
        }
      ]);
    const maryAddress = Cardano.PaymentAddress(
      'addr_test1qz690wvatwqgzt5u85hfzjxa8qqzthqwtp7xq8t3wh6ttc98hqtvlesvrpvln3srklcvhu2r9z22fdhaxvh2m2pg3nuq0n8gf2'
    );
    const bobAddress = Cardano.PaymentAddress(
      'addr_test1qr2c4k4zlych7qng2egjqmct5x03qshevmlemldykx8n3zmyyrjz7gnl09gp3yr23cwpwp9kszksps546zjchvmsfhnssu2sm4'
    );
    const handleAssetId = Cardano.AssetId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a6d617279');
    const handle = 'mary';

    it('it updates the owner of the handle when minting and transferring the same handle', async () => {
      const repository = queryRunner.manager.getRepository(HandleEntity);
      const source$ = createMultiTxProjectionSource([
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[handleAssetId, 1n]]),
            outputs: [
              {
                address: maryAddress,
                value: {
                  assets: new Map([[handleAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000')
        },
        {
          body: {
            fee: 123n,
            inputs: [],
            outputs: [
              {
                address: bobAddress,
                value: {
                  assets: new Map([[handleAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000001')
        }
      ]);

      const mintAndTransferEvt = await firstValueFrom(source$.pipe(applyOperators()));
      expect(mintAndTransferEvt.handles[0].handle).toEqual(handle);
      expect(await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle } })).toEqual({
        cardanoAddress: bobAddress,
        handle
      });
    });

    it('reverts address to the remaining owner when minting 2 handle assets and then burning 1', async () => {
      const mintTxId = Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000');
      const repository = queryRunner.manager.getRepository(HandleEntity);
      const source$ = createMultiTxProjectionSource([
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[handleAssetId, 2n]]),
            outputs: [
              {
                address: maryAddress,
                value: {
                  assets: new Map([[handleAssetId, 1n]]),
                  coins: 123n
                }
              },
              {
                address: bobAddress,
                value: {
                  assets: new Map([[handleAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: mintTxId
        },
        {
          body: {
            fee: 123n,
            inputs: [
              {
                // Burning handle owned by Bob, Mary's handle is now valid
                index: 1,
                txId: mintTxId
              }
            ],
            mint: new Map([[handleAssetId, -1n]]),
            outputs: []
          },
          id: Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000001')
        }
      ]);
      await firstValueFrom(source$.pipe(applyOperators()));
      expect(await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle } })).toEqual({
        cardanoAddress: maryAddress,
        handle
      });
    });

    it('ignores assets minted under the policy with a cip67 UserFT label', async () => {
      const mintTxId = Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000');
      const repository = queryRunner.manager.getRepository(HandleEntity);
      const invalidAssetName = Asset.AssetNameLabel.encode(Cardano.AssetName('ace'), Asset.AssetNameLabelNum.UserFT);
      const invalidAssetId = Cardano.AssetId.fromParts(policyId, invalidAssetName);
      const testAddress = Cardano.PaymentAddress(
        'addr_test1qz690wvatwqgzt5u85hfzjxa8qqzthqwtp7xq8t3wh6ttc98hqtvlesvrpvln3srklcvhu2r9z22fdhaxvh2m2pg3nuq0n8gf2'
      );

      const source$ = createMultiTxProjectionSource([
        {
          body: {
            fee: 111n,
            inputs: [],
            mint: new Map([[invalidAssetId, 1n]]),
            outputs: [
              {
                address: testAddress,
                value: {
                  assets: new Map([[invalidAssetId, 1n]]),
                  coins: 123n
                }
              }
            ]
          },
          id: mintTxId
        }
      ]);
      const numHandles = await repository.count();
      await firstValueFrom(source$.pipe(applyOperators()));

      expect(await repository.count()).toBe(numHandles);
    });
  });
});
