import { BaseProjectionEvent } from '@cardano-sdk/projection';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { HandleEntity } from '../../../src';
import { ProjectorContext, createProjectorContext, createStubProjectionSource } from '../util';
import { QueryRunner, Repository } from 'typeorm';
import { burnHandle, createMultiTxProjectionSource, entities, mapAndStore, projectTilFirst, queryHandle } from './util';
import { firstValueFrom } from 'rxjs';
import { initializeDataSource } from '../../util';

describe('storeHandles', () => {
  let queryRunner: QueryRunner;
  let context: ProjectorContext;
  let repository: Repository<HandleEntity>;

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    context = createProjectorContext(entities);
    repository = queryRunner.manager.getRepository(HandleEntity);
  });

  afterEach(async () => {
    await queryRunner.release();
  });

  it(`minting an existing handle sets address to null,
      rolling back a transaction that mint an existing handle sets address to the original owner`, async () => {
    const firstMintEvent = await projectTilFirst(context)(
      ({ handles, eventType }) => eventType === ChainSyncEventType.RollForward && handles[0]?.handle === 'bob'
    );
    const firstAddress = firstMintEvent.handles[0].latestOwnerAddress;
    expect(firstMintEvent.handles.length).toBe(1);
    const secondMintEvent = await projectTilFirst(context)(
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

    await projectTilFirst(context)(
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

  it('burning handle asset deletes it from the database', async () => {
    const mintEvent = await projectTilFirst(context)(({ handles }) => handles.length > 0);
    const firstMintedHandle = mintEvent.handles[0];
    expect(firstMintedHandle.latestOwnerAddress).toBeTruthy();
    const projectedHandleAfterMint = await queryHandle(firstMintedHandle.handle, repository);
    expect(projectedHandleAfterMint!.cardanoAddress).toBe(firstMintedHandle.latestOwnerAddress);

    await burnHandle(mintEvent, firstMintedHandle, context);

    await expect(queryHandle(firstMintedHandle.handle, repository)).resolves.toBeNull();
  });

  it('burning a handle with supply >1 sets address and datum to the 1 remaining owner', async () => {
    const burnEvent = await projectTilFirst(context)(
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
    const mintEvent1 = await projectTilFirst(context)(
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
    const mintEvt = await projectTilFirst(context)((evt) => evt.handles.length > 0);
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
    const transferEvt = await firstValueFrom(
      createStubProjectionSource([transferSourceEvt]).pipe(mapAndStore(context))
    );
    expect(transferEvt.handles[0].handle).toEqual(mintEvt.handles[0].handle);
    expect(transferEvt.handles[0].latestOwnerAddress).toEqual(newOwnerAddress);
    const handleInDbAfterTransfer = await repository.findOneBy({ handle: transferEvt.handles[0].handle });
    expect(handleInDbAfterTransfer?.cardanoAddress).toEqual(newOwnerAddress);

    const rollbackSourceEvt: BaseProjectionEvent = {
      ...transferEvt,
      eventType: ChainSyncEventType.RollBackward,
      point: mintEvt.block.header
    };
    await firstValueFrom(createStubProjectionSource([rollbackSourceEvt]).pipe(mapAndStore(context)));
    const handleInDbAfterTransferRollback = await repository.findOneBy({ handle: transferEvt.handles[0].handle });
    expect(handleInDbAfterTransferRollback?.cardanoAddress).toEqual(originalOwnerAddress);
  });

  describe('multiple transactions in 1 block', () => {
    const maryAddress = Cardano.PaymentAddress(
      'addr_test1qz690wvatwqgzt5u85hfzjxa8qqzthqwtp7xq8t3wh6ttc98hqtvlesvrpvln3srklcvhu2r9z22fdhaxvh2m2pg3nuq0n8gf2'
    );
    const bobAddress = Cardano.PaymentAddress(
      'addr_test1qr2c4k4zlych7qng2egjqmct5x03qshevmlemldykx8n3zmyyrjz7gnl09gp3yr23cwpwp9kszksps546zjchvmsfhnssu2sm4'
    );
    const handleAssetId = Cardano.AssetId('f0ff48bbb7bbe9d59a40f1ce90e9e9d0ff5002ec48f232b49ca0fb9a6d617279');
    const handle = 'mary';

    it('it updates the owner of the handle when minting and transferring the same handle', async () => {
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

      const mintAndTransferEvt = await firstValueFrom(source$.pipe(mapAndStore(context)));
      expect(mintAndTransferEvt.handles[0].handle).toEqual(handle);
      expect(await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle } })).toEqual({
        cardanoAddress: bobAddress,
        handle
      });
    });

    it('reverts address to the remaining owner when minting 2 handle assets and then burning 1', async () => {
      const mintTxId = Cardano.TransactionId('0000000000000000000000000000000000000000000000000000000000000000');
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
      await firstValueFrom(source$.pipe(mapAndStore(context)));
      expect(await repository.findOne({ select: { cardanoAddress: true, handle: true }, where: { handle } })).toEqual({
        cardanoAddress: maryAddress,
        handle
      });
    });
  });
});
