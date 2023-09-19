import {
  AssetEntity,
  OutputEntity,
  TokensEntity,
  TypeormStabilityWindowBuffer,
  createDataSource
} from '@cardano-sdk/projection-typeorm';
import { Bootstrap } from '@cardano-sdk/projection';
import { ChainSyncDataSet, chainSyncData, logger } from '@cardano-sdk/util-dev';
import { ProjectionName, createTypeormProjection, prepareTypeormProjection } from '../../src';
import { lastValueFrom } from 'rxjs';
import { projectorConnectionConfig, projectorConnectionConfig$ } from '../util';

describe('createTypeormProjection', () => {
  it('creates a projection to PostgreSQL based on requested projection names', async () => {
    // Setup
    const projections = [ProjectionName.UTXO];
    const buffer = new TypeormStabilityWindowBuffer({ allowNonSequentialBlockHeights: true, logger });
    const { entities } = prepareTypeormProjection({ buffer, projections }, { logger });
    const dataSource = createDataSource({
      connectionConfig: projectorConnectionConfig,
      devOptions: { dropSchema: true, synchronize: true },
      entities,
      logger
    });
    await dataSource.initialize();
    const queryRunner = dataSource.createQueryRunner();
    await queryRunner.connect();
    const data = chainSyncData(ChainSyncDataSet.WithMint);
    await buffer.initialize(queryRunner);

    const projection$ = createTypeormProjection({
      blocksBufferLength: 10,
      buffer,
      connectionConfig$: projectorConnectionConfig$,
      devOptions: { dropSchema: true, synchronize: true },
      logger,
      projectionSource$: Bootstrap.fromCardanoNode({
        blocksBufferLength: 10,
        buffer,
        cardanoNode: data.cardanoNode,
        logger
      }),
      projections
    });

    // Project
    await lastValueFrom(projection$);

    // Check data in the database
    expect(await queryRunner.manager.count(AssetEntity)).toBeGreaterThan(0);
    expect(await queryRunner.manager.count(TokensEntity)).toBeGreaterThan(0);
    expect(await queryRunner.manager.count(OutputEntity)).toBeGreaterThan(0);
    await queryRunner.release();
    await dataSource.destroy();
  });

  // PostgreSQL transaction retries are tested in projection-typeorm package
});
