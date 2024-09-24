import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  NftMetadataEntity,
  TypeormStabilityWindowBuffer,
  TypeormTipTracker,
  createObservableConnection,
  storeAssets,
  storeBlock,
  typeormTransactionCommit,
  willStoreAssets,
  withTypeormTransaction
} from '../../src';
import { Bootstrap, ChainSyncEventType, Mappers, requestNext } from '@cardano-sdk/projection';
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { Mint } from '@cardano-sdk/projection/dist/cjs/operators/Mappers';
import { QueryRunner } from 'typeorm';
import { connectionConfig$, initializeDataSource } from '../util';
import { createProjectorContext, createProjectorTilFirst } from './util';

describe('storeAssets', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithMint);
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  let tipTracker: TypeormTipTracker;
  const entities = [BlockEntity, BlockDataEntity, AssetEntity, NftMetadataEntity];

  const project$ = () =>
    Bootstrap.fromCardanoNode({
      blocksBufferLength: 10,
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger,
      projectedTip$: tipTracker.tip$
    }).pipe(
      Mappers.withMint(),
      withTypeormTransaction({
        connection$: createObservableConnection({ connectionConfig$, entities, logger })
      }),
      storeBlock(),
      storeAssets(),
      buffer.storeBlockData(),
      typeormTransactionCommit(),
      tipTracker.trackProjectedTip(),
      requestNext()
    );

  const projectTilFirst = createProjectorTilFirst(project$);

  beforeEach(async () => {
    const dataSource = await initializeDataSource({ entities });
    queryRunner = dataSource.createQueryRunner();
    ({ buffer, tipTracker } = createProjectorContext(entities));
    tipTracker.tip$.subscribe((tip) => logger.info('NEW TIP', tip));
  });

  afterEach(async () => {
    await queryRunner.release();
  });

  it('inserts assets on mint, deletes when 1st mint block is rolled back', async () => {
    const repository = queryRunner.manager.getRepository(AssetEntity);
    const mintEvent = await projectTilFirst((evt) => evt.mint.length > 0);
    expect(Object.values(mintEvent.mintedAssetTotalSupplies)).toHaveLength(mintEvent.mint.length);
    const firstMintedAssetTotalSupply = mintEvent.mintedAssetTotalSupplies[mintEvent.mint[0].assetId]!;
    expect(firstMintedAssetTotalSupply).toBeGreaterThan(0);
    expect(await repository.count()).toBe(mintEvent.mint.length);
    const firstDbMint = await repository.findOne({ where: { id: mintEvent.mint[0].assetId } });
    expect(firstDbMint?.supply).toBe(mintEvent.mint[0].quantity);
    const rollbackEvent = await projectTilFirst(
      (evt) =>
        evt.block.header.hash === mintEvent.block.header.hash && evt.eventType === ChainSyncEventType.RollBackward
    );
    expect(await repository.count()).toBe(0);
    expect(rollbackEvent.mintedAssetTotalSupplies[rollbackEvent.mint[0].assetId]).toEqual(
      firstMintedAssetTotalSupply - mintEvent.mint[0].quantity
    );
  });

  it('increments asset supply on second mint, decrements when second mint block is rolled back', async () => {
    // Find some asset that has been minted more than once
    const numberOfAssetMintEvents: Record<Cardano.AssetId, number> = {};
    const secondMintEvent = await projectTilFirst((evt) => {
      for (const { assetId } of evt.mint) {
        if (evt.eventType === ChainSyncEventType.RollForward) {
          numberOfAssetMintEvents[assetId] = (numberOfAssetMintEvents[assetId] || 0) + 1;
        } else {
          numberOfAssetMintEvents[assetId] = (numberOfAssetMintEvents[assetId] || 0) - 1;
        }
        if (numberOfAssetMintEvents[assetId] > 1) {
          return true;
        }
      }
      return false;
    });
    expect(secondMintEvent.mint.length).toBeGreaterThan(0);
    const assetIdThatWasMintedTwice = Object.entries(numberOfAssetMintEvents).find(
      ([_, numberOfMints]) => numberOfMints > 1
    )![0] as Cardano.AssetId;
    const totalSupplyAfterSecondMint = secondMintEvent.mintedAssetTotalSupplies[assetIdThatWasMintedTwice]!;
    expect(totalSupplyAfterSecondMint).not.toBeUndefined();
    logger.info('Before 2nd project');
    const rollbackEvent = await projectTilFirst(
      (evt) =>
        evt.eventType === ChainSyncEventType.RollBackward && evt.block.header.hash === secondMintEvent.block.header.hash
    );
    expect(secondMintEvent.mint.length).toBeGreaterThan(0);
    expect(rollbackEvent.mintedAssetTotalSupplies[assetIdThatWasMintedTwice]).toBeLessThan(totalSupplyAfterSecondMint);
    expect(rollbackEvent.mintedAssetTotalSupplies[assetIdThatWasMintedTwice]).toBeGreaterThan(0);
  });
});

describe('willStoreAssets', () => {
  it('returns true if there are mints', () => {
    expect(
      willStoreAssets({
        mint: [{} as Mint]
      })
    ).toBeTruthy();
  });

  it('returns false if there are no mints', () => {
    expect(
      willStoreAssets({
        mint: []
      })
    ).toBeFalsy();
  });
});
