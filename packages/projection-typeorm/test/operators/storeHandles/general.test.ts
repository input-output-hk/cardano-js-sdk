import { Asset, Cardano } from '@cardano-sdk/core';
import { AssetEntity, HandleEntity, OutputEntity, willStoreHandles } from '../../../src';
import { ChainSyncEventType } from '@cardano-sdk/projection';
import { HandleOwnership } from '@cardano-sdk/projection/dist/cjs/operators/Mappers';
import { ProjectorContext, createProjectorContext } from '../util';
import { QueryRunner } from 'typeorm';
import { createMultiTxProjectionSource, entities, mapAndStore, policyId, projectTilFirst } from './util';
import { firstValueFrom } from 'rxjs';
import { initializeDataSource } from '../../util';

describe('storeHandles', () => {
  let queryRunner: QueryRunner;
  let context: ProjectorContext;

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    context = createProjectorContext(entities);
  });

  afterEach(async () => {
    await queryRunner.release();
  });

  it('inserts handle on mint', async () => {
    const repository = queryRunner.manager.getRepository(HandleEntity);
    const mintEvent = await projectTilFirst(context)((evt) => evt.handles.length > 0);
    expect(await repository.count()).toBe(mintEvent.handles.length);
    expect(mintEvent.handles.length).toBeGreaterThan(0);
  });

  it('when combined with filter operators, stores only relevant Output and Asset (per handle)', async () => {
    const outputRepository = queryRunner.manager.getRepository(OutputEntity);
    const assetRepository = queryRunner.manager.getRepository(AssetEntity);
    const { handles } = await projectTilFirst(context)((evt) => evt.handles.length > 0);
    expect(await outputRepository.count()).toBe(handles.length);
    expect(await assetRepository.count()).toBe(handles.length);
  });

  it('deletes handle on rollback', async () => {
    const handleRepository = queryRunner.manager.getRepository(HandleEntity);
    const initialCount = await handleRepository.count();
    const mintEvent = await projectTilFirst(context)(
      ({ handles, eventType }) => eventType === ChainSyncEventType.RollForward && handles.length > 0
    );
    expect(await handleRepository.count()).toEqual(initialCount + mintEvent.handles.length);
    await projectTilFirst(context)(
      ({
        eventType,
        block: {
          header: { hash }
        }
      }) => eventType === ChainSyncEventType.RollBackward && hash === mintEvent.block.header.hash
    );
    expect(await handleRepository.count()).toEqual(initialCount);
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
    await firstValueFrom(source$.pipe(mapAndStore(context)));

    expect(await repository.count()).toBe(numHandles);
  });
});

describe('willStoreHandles', () => {
  it('returns true if handles are bigger than 1', () => {
    expect(
      willStoreHandles({
        handles: [{} as HandleOwnership]
      })
    ).toBeTruthy();
  });

  it('returns false if there are no handles', () => {
    expect(
      willStoreHandles({
        handles: []
      })
    ).toBeFalsy();
  });
});
