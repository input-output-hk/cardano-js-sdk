import {
  AssetEntity,
  BlockDataEntity,
  BlockEntity,
  NftMetadataEntity,
  TypeormStabilityWindowBuffer,
  storeAssets,
  storeBlock,
  typeormTransactionCommit,
  withTypeormTransaction
} from '../../src';
import { Bootstrap, Mappers, requestNext } from '@cardano-sdk/projection';
import { Cardano, ChainSyncEventType } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { DataSource, QueryRunner } from 'typeorm';
import { Observable, of } from 'rxjs';
import { createProjectorTilFirst } from './util';
import { initializeDataSource } from '../util';

describe('storeAssets', () => {
  const stubEvents = chainSyncData(ChainSyncDataSet.WithMint);
  let queryRunner: QueryRunner;
  let buffer: TypeormStabilityWindowBuffer;
  let dataSource$: Observable<DataSource>;
  const entities = [BlockEntity, BlockDataEntity, AssetEntity, NftMetadataEntity];

  const project$ = () =>
    Bootstrap.fromCardanoNode({
      buffer,
      cardanoNode: stubEvents.cardanoNode,
      logger
    }).pipe(
      Mappers.withMint(),
      withTypeormTransaction({
        dataSource$,
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
    dataSource$ = of(dataSource);
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
    const rollbackEvent = await projectTilFirst(
      (evt) =>
        evt.eventType === ChainSyncEventType.RollBackward && evt.block.header.hash === secondMintEvent.block.header.hash
    );
    expect(secondMintEvent.mint.length).toBeGreaterThan(0);
    expect(rollbackEvent.mintedAssetTotalSupplies[assetIdThatWasMintedTwice]).toBeLessThan(totalSupplyAfterSecondMint);
    expect(rollbackEvent.mintedAssetTotalSupplies[assetIdThatWasMintedTwice]).toBeGreaterThan(0);
  });
});
