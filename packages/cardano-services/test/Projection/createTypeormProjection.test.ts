/* eslint-disable @typescript-eslint/no-explicit-any */
import {
  AssetEntity,
  BlockEntity,
  OutputEntity,
  TokensEntity,
  createDataSource
} from '@cardano-sdk/projection-typeorm';
import { Cardano } from '@cardano-sdk/core';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { ChainSyncEventType } from '@cardano-sdk/projection';
import { ProjectionName, createTypeormProjection, prepareTypeormProjection } from '../../src';
import { lastValueFrom } from 'rxjs';
import { projectorConnectionConfig, projectorConnectionConfig$ } from '../util';

describe('createTypeormProjection', () => {
  it('creates a projection to PostgreSQL based on requested projection names', async () => {
    // Setup projector
    const projections = [ProjectionName.UTXO];
    const data = chainSyncData(ChainSyncDataSet.WithMint);
    const projection$ = createTypeormProjection({
      blocksBufferLength: 10,
      cardanoNode: data.cardanoNode,
      connectionConfig$: projectorConnectionConfig$,
      devOptions: { dropSchema: true },
      logger,
      projections
    });

    // Project
    await lastValueFrom(projection$);

    // Setup query runner for assertions
    const { entities } = prepareTypeormProjection({ projections }, { logger });
    const dataSource = createDataSource({
      connectionConfig: projectorConnectionConfig,
      entities,
      logger
    });
    await dataSource.initialize();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.connect();

    // Check data in the database
    expect(await queryRunner.manager.count(AssetEntity)).toBeGreaterThan(0);
    expect(await queryRunner.manager.count(TokensEntity)).toBeGreaterThan(0);
    expect(await queryRunner.manager.count(OutputEntity)).toBeGreaterThan(0);

    await queryRunner.release();
    await dataSource.destroy();
  });

  it('only store blocks which have relevant information to the configured stores', async () => {
    // Setup projector
    const projections = [ProjectionName.Asset];
    const data = chainSyncData(ChainSyncDataSet.WithMint);

    const emptyBlocksHashes = data.allEvents
      .filter((evt) => (evt as any).block && (evt as any).block.body.length === 0)
      .map((evt) => (evt as any).block.header.hash);

    // Make sure our empty blocks are outside the stability window.
    for (const event of data.allEvents) {
      if (event.eventType === ChainSyncEventType.RollForward && emptyBlocksHashes.includes(event.block.header.hash))
        event.tip.blockNo = Cardano.BlockNo(Number.MAX_SAFE_INTEGER);
    }

    const projection$ = createTypeormProjection({
      blocksBufferLength: 10,
      cardanoNode: data.cardanoNode,
      connectionConfig$: projectorConnectionConfig$,
      devOptions: { dropSchema: true },
      logger,
      projections
    });

    // Project
    await lastValueFrom(projection$);

    // Setup query runner for assertions
    const { entities } = prepareTypeormProjection({ projections }, { logger });
    const dataSource = createDataSource({
      connectionConfig: projectorConnectionConfig,
      entities,
      logger
    });
    await dataSource.initialize();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.connect();

    // Check data in the database
    for (const emptyBlockHash of emptyBlocksHashes)
      expect(
        await queryRunner.manager.getRepository(BlockEntity).findOne({ where: { hash: emptyBlockHash } })
      ).toBeNull();

    expect.hasAssertions();

    await queryRunner.release();
    await dataSource.destroy();
  });
  // PostgreSQL transaction retries are tested in projection-typeorm package
});
